class LegacySection < LegacyData
  set_table_name "articletype"
  set_inheritance_column "legacy_type"
  before_create :set_defaults
  cattr_accessor :callbacks, :import_to_class
  import_to :page

  AMP_ROOT = 1
  AMP_TRASH = 2

  IMPORT_KEYS = {
    :page => {
      :name => :type,
      :tag  => :simple_name,
      #:parent_page_id => :confirm_parent_page,
      :redirect_to => :linkurl,
      :legacy_id => :id,
      :created_at => :timestamp
    }
  }
  after_import :create_primary_placement

  def set_defaults
    self.timestamp ||= Time.now
  end

  def simple_name
    simplify_tag type
  end

  def confirm_parent_page
    return unless parent
    return if parent == AMP_TRASH
    parent_page = Site.first.landing_page if parent == AMP_ROOT 
    parent_page ||= Page.find_by_legacy_id parent
    unless parent_page
      parent_section = LegacySection.find parent
      parent_page = parent_section.import
    end
    parent_page.id
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def create_primary_placement
    parent_page_id = confirm_parent_page
    return unless parent_page_id
    imported.parent_placements.create :page_id => parent_page_id, :canonical => true, :list_order => textorder
  end

  def import
    return if [ AMP_ROOT, AMP_TRASH ].include?(id)
    super
  end
end
