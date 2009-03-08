class LegacyImage < LegacyData
  set_table_name :images
  set_inheritance_column "legacy_type"
  cattr_accessor :callbacks, :import_to_class
  import_to :media

  IMPORT_KEYS = {
    :media => {
      :image => :original_image_file,
      :caption => :caption,
      :alt_text => :alt,
      :legacy_id => :id,
      :media_created_on => :date,
      :license => :license
    }
  }

  def original_image_file
    File.open "#{RAILS_ROOT}/public/legacy/img/original/#{name}", 'r'
  end

  def import
    return unless File.exists? "#{RAILS_ROOT}/public/legacy/img/original/#{name}"
    super
  end
end
