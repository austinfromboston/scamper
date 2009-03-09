class LegacyArticle < LegacyData
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  cattr_accessor :callbacks, :import_to_class

  set_table_name "articles"
  set_inheritance_column "legacy_type"
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
  AMP_CLASSES_WHICH_DO_NOT_AGGREGATE = {
    1   => "general_content",
    8   => "section_header"
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
      :legacy_id  => :id,
      :legacy_type => 'article',
      :title      => :title,
      :subtitle   => :subtitile,
      :body_html  => :body_as_html,
      :body       => :test,
      :blurb      => :shortdesc,
      :published_at => :clean_date,
      :status     => :publishing_status,
      :created_at => :datecreated,
      :updated_at => :updated
      #:created_by_id => { confirm_user( enteredby ) },
      #:updated_by_id => { confirm_user( updatedby ) } 
      #:author_id => :confirm_author,
    },
    :page => {
      :name             => :title,
      :redirect_to      => :link,
      :metakeywords     => :metakeywords,
      :metadescription  => :metadescription,
      :created_at       => :datecreated,
      :updated_at       => :updated,
      #:url  => :permalink,
      #:parent_page_id => :confirm_parent_page,
      #:placements => :create_primary_placement
    },
    :placement => {
      #:list_order => :pageorder,
      :view_type => :class_as_named_display
    }
  }

  after_import\
    :create_primary_placement, 
    :create_frontpage_placement, 
    :create_class_placements,
    :create_latest_placements,
    :create_tag_placements,
    :create_section_placements,
    :create_related_section_placements #,
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
    self.imported_page = local_object( Page )
    imported_page.save
    imported_page
  end

  def class_as_named_display
    AMP_CLASSES_WITH_CUSTOM_DISPLAYS[amp_class] 
  end

  def create_frontpage_placement
    imported.placements.create( :page => Site.first.landing_page ) if fplink == 1
  end

  def create_class_placements
    return if amp_class.nil? or AMP_CLASSES_WHICH_DO_NOT_AGGREGATE[amp_class]
    old_class = LegacyClass.find_by_id amp_class

    class_tag = old_class ? simplify_tag(old_class.amp_class) : AMP_CLASSES_WHICH_AGGREGATE[amp_class]
    
    # search for existing import
    class_page = Page.find_by_tag class_tag

    # import the Legacy Class
    class_page ||= old_class.import if old_class
    
    # use a created page
    class_page ||= Page.create :tag => class_tag, :name => AMP_CLASSES_WHICH_AGGREGATE[amp_class].titleize, :legacy_id => amp_class, :legacy_type => 'class'
    imported.placements.create :page => class_page, :view_type => 'list/default'
  end

  def create_latest_placements
    return unless read_attribute( :new ) && !read_attribute( :new ).zero?
    tag_page = Page.find_by_tag 'new_items'
    tag_page ||= Page.create :tag => 'new_items', :name => 'New items'
    imported.placements.create :page => tag_page, :view_type => 'list/default'
  end

  def create_tag_placements
    taggings = LegacyTagging.find_all_by_item_id_and_item_type( id, 'article' )
    return if taggings.empty?
    tags = taggings.map { |t| LegacyTag.find_by_id t.tag_id }.compact
    tags.each do |tag|
      simple_tag = simplify_tag( tag.name )
      tag_page = Page.find_by_tag( simple_tag )
      tag_page ||= Page.create :tag => simple_tag, :name => tag.name.titleize, :legacy_id => tag.id, :legacy_type => 'tag'
      imported.placements.create :page => tag_page, :view_type => 'list/default'
    end
  end

  def create_section_placements
    return unless type
    return if amp_class == AMP_CLASSES['section_header']
    section_page = Page.find_by_legacy_id_and_legacy_type type, "section"
    section = LegacySection.find type
    unless section_page
      raise TrashedItemImport if section.parent == LegacySection::AMP_TRASH
      section_page = section.import  
    end
    imported.placements.create :page => section_page, :list_order => pageorder, :assigned_order => pageorder, :view_type => ( section.show_list? ? 'list/default' : 'hidden' )
  rescue ActiveRecord::RecordNotFound
    nil

  end

  def create_related_section_placements
=begin
    rel_sections = LegacyRelatedSection.find_all_by_articleid id
    rel_sections.each { |r| r.import }
=end
  end

  def confirm_section_header_placement
    return unless type
    section_page = Page.find_by_legacy_id_and_legacy_type type, "section"
    unless section_page
      begin
        section = LegacySection.find type
      rescue ActiveRecord::RecordNotFound
        raise OrphanItemImport
      end
      raise TrashedItemImport if section.parent == LegacySection::AMP_TRASH
      section_page = section.import #Page.create :tag => simplify_tag( section.type ), :name => title
      section_page.update_attributes :name => title
    end
    imported.placements.create :page => section_page, :canonical => true, :view_type => "header"
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def import
    return if Article.find_by_legacy_id_and_legacy_type id, 'article'
    super
  end

  def kill_tree
    log "killing tree for LA #{id}"
    imported ||= Article.find_by_legacy_id_and_legacy_type id, "article"
    imported.primary_page.delete if imported.primary_page
    log "killing placements for LA #{id}"
    imported.placements.delete_all
    section = LegacySection.find type
    section.kill_tree
  rescue 
    nil
  ensure
    log "final delete for LA #{id}"
    imported.delete if imported

  end


end
