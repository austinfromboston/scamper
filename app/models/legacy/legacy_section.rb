class LegacySection < LegacyData
  set_table_name "articletype"
  set_inheritance_column nil
  before_create :set_defaults
  cattr_accessor :callbacks, :import_to_class
  import_to :page

  AMP_ROOT = 1
  AMP_TRASH = 2

  IMPORT_KEYS = {
    :page => {
      :name => :type,
      :tag  => :simple_name,
      :parent_page_id => :confirm_parent_page,
      :redirect_to => :linkurl,
      :created_at => :timestamp
    }
  }
  def set_defaults
    self.timestamp ||= Time.now
  end

  def simple_name
    simplify_tag type
  end

  def confirm_parent_page
    return unless parent
    return if parent == AMP_ROOT or parent == AMP_TRASH
    parent_page = Page.find_by_legacy_id parent
    unless parent_page
      parent_section = LegacySection.find parent
      return unless parent_section
      parent_page = parent_section.import
    end
    parent_page
  end
end
