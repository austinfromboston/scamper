class LegacyNavLayout < LegacyData
  set_table_name 'nav_layouts'
  set_inheritance_column 'legacy_type'
  cattr_accessor :import_to_class, :callbacks

  import_to :page
  IMPORT_KEYS = {
    :page => {
      :name => lambda { |nl| "Navs for #{nl.name} ( #{nl.nav_side} )" },
      :page_layout_id => :confirm_page_layout,
      :legacy_id => :id,
      :legacy_type => lambda { |nl| 'nav_layout_' + nl.nav_side }
    }
  }

  after_import :confirm_placement

  attr_accessor :nav_side

  def nav_side
    @nav_side || 'left'
  end

  def confirm_page_layout
    lt = LegacyTemplate.find( LegacySite.first.template )
    layout = lt.import_nav
    layout.id
  end

  AMP_INTROTEXTS = {
    'content'   => 1,
    'frontpage' => 2,
    'articles'  => 3
  }

  def confirm_placement
    return unless LegacyNavLocation.count( :conditions => [ "layout_id = ? and position like ?", id, "%#{nav_side[0,1]}%" ] ) > 0

    if section_id and !section_id.zero?
      page = Page.find_by_legacy_id_and_legacy_type(section_id, "section")
      return unless page
      page.descendents.each do |p| 
        unless p.placements.find_by_view_type "#{nav_side}_nav"
          p.placements.create :child_page_id => imported.id, :block => nav_side, :view_type => "#{nav_side}_nav"
        end
      end
    end

    if class_id and !class_id.zero?
      page = Page.find_by_legacy_id_and_legacy_type(section_id, "class")
      return unless page
      page.placements.create :child_page_id => imported.id, :block => nav_side, :view_type => "#{nav_side}_nav"
    end

    if introtext_id  == AMP_INTROTEXTS['content']
      log "Creating default navs for all pages"
      Page.all(:conditions => ["legacy_type not like ?", "%nav_layout%" ] ).each do |page|
        next if page.placements.find_by_block nav_side
        page.placements.create :child_page_id => imported.id, :block => nav_side, :view_type => "#{nav_side}_nav"
      end
    end

    if introtext_id  == AMP_INTROTEXTS['frontpage']
      page = Site.first.landing_page
      page.placements.create :child_page_id => imported.id, :block => nav_side, :view_type => "#{nav_side}_nav"
    end

    if introtext_id  == AMP_INTROTEXTS['articles']
      log "installing article nav layouts"
      pages = Page.all :conditions => [ "tag = ? and legacy_id = ?", nil, nil ]
      pages.each do |page|
        next if page.placements.count > 1 or page.primary_article.nil?
        page.placements.create :child_page_id => imported.id, :block => nav_side, :view_type => "#{nav_side}_nav"
        
      end
    end
      
  end

  def import 
    return unless LegacyNavLocation.count( :conditions => [ "layout_id = ? and position like ?", id, "%#{nav_side[0,1]}%" ] ) > 0
    super
  end

end
