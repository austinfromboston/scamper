class LegacyNavLayout < LegacyData
  set_table_name 'nav_layouts'
  set_inheritance_column 'legacy_type'
  cattr_accessor :import_to_class, :callbacks

  import_to :page
  IMPORT_KEYS = {
    :page => {
      :name => :name,
      :page_layout_id => :confirm_page_layout
    }
  }

  after_import :import_right_side, :confirm_placement

  attr_accessor :nav_side

  def nav_side
    'left' unless @nav_side
  end

  def confirm_page_layout
    lt = LegacyTemplate.find( LegacySite.first.template )
    lt.import_nav
  end
  def confirm_placement
    
  end
end
