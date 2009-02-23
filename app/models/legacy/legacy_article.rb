class LegacyArticle < LegacyData
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  #establish_connection configurations[ ( Rails.env.test? ? 'legacy_test' : 'legacy' ) ]
  set_table_name "articles"
  set_inheritance_column nil
  import_to :article

  AMP_CLASSES_WITH_CUSTOM_DISPLAYS = {
    2  => "front_page",
    3  => "news",
    4  => "news",
    10 => "press_release"
  }
  AMP_CLASSES_WHICH_AGGREGATE = {
    2   => "front_page",
    3   => "news",
    4   => "news",
    5   => "action_alert",
    9   => "user_submitted",
    10  => "press_release",
    20  => "blog"
  }
  AMP_CLASSES_OF_DOOM = {
    8   => "section_header",
  }
  AMP_CLASSES = AMP_CLASSES_WITH_CUSTOM_DISPLAYS.merge(  
                AMP_CLASSES_WHICH_AGGREGATE ).merge(  
                AMP_CLASSES_OF_DOOM ).invert

  attr_accessor :imported_page

  IMPORT_KEYS = {
    :article => {
      :legacy_id => :id,
      :title => :title,
      :subtitle => :subtitile,
      :body_html => :body_as_html,
      :body => :test,
      :blurb => :shortdesc,
      :published_at => :clean_date,
      :status => :publishing_status,
      :created_at => :datecreated,
      :updated_at => :updated
      #:created_by_id => { confirm_user( enteredby ) },
      #:updated_by_id => { confirm_user( updatedby ) } 
      #:author_id => :confirm_author,
    },
    :page => {
      :name => :title,
      :redirect_to => :link,
      :metakeywords => :metakeywords,
      :metadescription => :metadescription,
      :created_at => :datecreated,
      :updated_at => :updated,
      #:url  => :permalink,
      #:parent_page_id => :confirm_parent_page,
      #:placements => :create_primary_placement
    },
    :placement => {
      #:list_order => :pageorder,
      :display => :class_as_named_display
    }
  }

  after_import\
    :create_primary_placement, 
    :create_frontpage_placement, 
    :create_class_placements,
    :create_latest_placements,
    :create_tag_placements,
    :create_section_placements #,
#    :place_images

  def body_as_html
    return test if html?
    simple_format test
  end

  # this should take account of the various null-equivalents in AMP
  def clean_date
    read_attribute :date
  end

  def publishing_status
    case publish
      when 3; "revision"
      when 2; "pending"
      when 1; "live"
      else "draft"
    end
  end

  def create_primary_placement
    return confirm_section_header_placement if amp_class == AMP_CLASSES['section_header']
    imported.placements.create!( 
      { :page => create_primary_page, :canonical => true }.
        merge(  local_attributes( :placement ) )
      )
  end

  def create_primary_page
    Page.establish_connection
    self.imported_page = local_object( Page )
    imported_page.save
    imported_page
  end

  def class_as_named_display
    AMP_CLASSES_WITH_CUSTOM_DISPLAYS[amp_class] 
  end

  def create_frontpage_placement
    imported.placements.create :page => Site.first.landing_page
  end

  def create_class_placements
    return unless AMP_CLASSES_WHICH_AGGREGATE[amp_class]
    class_page = Page.find_or_create_by_tag AMP_CLASSES_WHICH_AGGREGATE[amp_class]
    imported.placements.create :page => class_page
  end

  def create_latest_placements
    return unless read_attribute( :new ) && !read_attribute( :new ).zero?
    tag_page = Page.find_or_create_by_tag 'new'
    imported.placements.create :page => tag_page
  end

  def create_tag_placements
    taggings = LegacyTagging.find_all_by_content_foreign_key_and_content_type( id, 'article' )
    return if taggings.empty?
    tags = taggings.map { |t| LegacyTag.find t.tag_id }.compact
    tags.each do |tag|
      simple_tag = simplify_tag( tag.name )
      tag_page = Page.find_by_tag( simple_tag )
      tag_page ||= Page.create :tag => simple_tag, :name => tag.name.titleize
      imported.placements.create :page => tag_page
    end
  end

  def simplify_tag( value )
    value.downcase.gsub( /[^a-z0-9_]/, '_' )
  end

  def create_section_placements
    return unless type
    return if amp_class == AMP_CLASSES['section_header']
    section_page = Page.find_by_legacy_id type
    unless section_page
      section = LegacySection.find type
      section_page = Page.create :tag => simplify_tag( section.type )
    end
    imported.placements.create :page => section_page, :list_order => pageorder

  end

  def confirm_section_header_placement
    return unless type
    section_page = Page.find_by_legacy_id type
    unless section_page
      section = LegacySection.find type
      section_page = Page.create :tag => simplify_tag( section.type ), :name => title
    end
    imported.placements.create :page => section_page, :canonical => true, :display => "header"
  end


end
