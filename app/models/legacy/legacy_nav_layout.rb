class LegacyNavLayout < LegacyData
  set_table_name 'nav_layouts'
  set_inheritance_column 'legacy_type'
  cattr_accessor :import_to_class, :callbacks

  import_to :page
  IMPORT_KEYS = {
    :page => {
      :name => :name,
      :page_layout_id => :confirm_page_layout,
      :legacy_id => :id,
      :legacy_type => lambda { |nl| 'nav_layout' + nl.nav_side }
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

  def confirm_placement
    if section_id and !section_id.zero?
      page = Page.find_by_legacy_id(section_id)
      return unless page
      page.descendents.each do |p| 
        unless p.placements.find_by_display "#{nav_side}_nav"
          p.placements.create :child_page_id => imported.id, :block => nav_side, :display => "#{nav_side}_nav"
        end
      end
    end
      
  end

end
