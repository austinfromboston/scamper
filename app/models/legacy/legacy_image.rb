class LegacyImage < LegacyData
  set_table_name :images
  set_inheritance_column "legacy_type"
  cattr_accessor :callbacks, :import_to_class
  import_to :media

  AMP_FORM_DATE_DEFAULT = Date.new( 2000, 1, 1 )
  ORIGINAL_PATH = "#{RAILS_ROOT}/public/legacy/img/original/"


  IMPORT_KEYS = {
    :media => {
      :image => :original_image_file,
      :caption => :caption,
      :alt_text => :alt,
      :legacy_id => :id,
      :media_created_on => :verified_date,
      :license => :license
    }
  }

  after_import :place_in_articles

  def original_image_file
    File.open(( ORIGINAL_PATH + name ), 'r')
  end

  def verified_date
    date unless date == AMP_FORM_DATE_DEFAULT
  end

  def import
    return unless File.exists?( ORIGINAL_PATH + name )
    existing_image = Media.find_by_legacy_id( id )
    if existing_image
      self.imported = existing_image
    else
      super
    end
  end

  def place_in_articles
    arts = LegacyArticle.find_all_by_picture imported.image.original_filename
    arts.each do |legacy_art|
      art = Article.find_by_legacy_id_and_legacy_type(legacy_art.id, 'article' )
      next unless art && art.primary_page
      art.primary_page.placements.create :child_item => imported, :list_order => 1, :canonical => true, :assigned_order => 1
      art.primary_placement.update_attributes :list_order => 2, :assigned_order => 2
      sync_legacy_article_info( legacy_art, imported )
      log "placed #{imported.image.original_filename} on #{art.primary_page.name}"
    end
  end

  def sync_legacy_article_info(legacy_article, image )
    if legacy_article.piccap.present? and !legacy_article.piccap.blank?
      imported.caption ||= legacy_article.piccap
    end
    if legacy_article.alttag.present? and !legacy_article.alttag.blank?
      imported.alt_text ||= legacy_article.alttag
    end
    imported.save if imported.changed?
  end
end
