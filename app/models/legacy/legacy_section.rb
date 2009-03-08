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
      :parent_page_id => :confirm_parent_page,
      :tree_order => lambda { |ls| ls.textorder if ls.textorder and !ls.textorder.zero? },
      :redirect_to => :linkurl,
      :legacy_id => :id,
      :legacy_type => 'section',
      :created_at => :timestamp
    }
  }
  after_import :place_banner_image

  def set_defaults
    self.timestamp ||= Time.now
  end

  def simple_name
    simplify_tag type
  end

  def confirm_parent_page
    raise OrphanItemImport unless parent
    return if parent == AMP_TRASH
    parent_page = Site.first.landing_page if parent == AMP_ROOT 
    parent_page ||= Page.find_by_legacy_id_and_legacy_type( parent, 'section' )
    unless parent_page
      begin
        parent_section = LegacySection.find parent
      rescue ActiveRecord::RecordNotFound
        raise OrphanItemImport
      end
      parent_page = parent_section.import
    end
    parent_page.id
  rescue ActiveRecord::RecordNotFound
    nil
  end

=begin
  def create_primary_placement
    parent_page_id = confirm_parent_page
    return unless parent_page_id
    imported.parent_placements.create :page_id => parent_page_id, :canonical => true, :list_order => textorder
  end
=end

  def import
    raise TrashedItemImport if AMP_TRASH == id
    return if AMP_ROOT == id
    super
  end

  def kill_tree
    imported ||= Page.find_by_legacy_id_and_legacy_type id, 'section'
    #log "killing placements for Section #{id}"
    #imported.placements.delete_all if imported
    log "killing parent for Section #{id}"
    lp = LegacySection.find parent
    lp.kill_tree 
  rescue 
    nil
  ensure

    log "final delete for Section #{id}"
    imported.delete if imported
    Page.delete_all [ "legacy_id = ? and legacy_type = ?", id, "section" ]

  end

  def inherited_flash
    return flash if flash && !flash.blank?
    return if parent.nil? or [ 0, AMP_ROOT, AMP_TRASH ].include?( parent )
    parent_section = LegacySection.find parent
    parent_section.inherited_flash if parent_section
  end

  def place_banner_image
    banner_image = inherited_flash
    return unless banner_image 
    log "banner image #{banner_image} found for Section #{type}"
    imported ||= Page.find_by_legacy_id_and_legacy_type id, 'section'
    image = Media.find_by_image_file_name( banner_image )
    if image.nil?
      legacy_image = LegacyImage.find_by_name banner_image
      if legacy_image
        image = legacy_image.import 
      else
        return unless File.exists?( LegacyImage::ORIGINAL_PATH + banner_image )
        File.open( (LegacyImage::ORIGINAL_PATH + banner_image ), 'r' ) do |f|
          image = Media.create :image => f
        end
      end
    end

    log "placing banner image #{banner_image} on page #{imported.to_param}"
    image.placements.create :page => imported, :block => 'banner', :view_type => 'raw_original'
  end
end
