class LegacySite < LegacyData
  set_table_name 'sysvar'
  cattr_accessor :callbacks, :import_to_class
  set_inheritance_column "legacy_type"
  import_to :site

  IMPORT_KEYS = {
    :site => {
      :name => :websitename,
      :url  => :basepath
    },
    :page => {
      :name => :websitename,
      :metakeywords => :metacontent,
      :metadescription => :metadescription
    }
  }
  after_import :create_landing_page
  def create_landing_page
    lp = local_object Page 
    lp.save
    imported.update_attribute :landing_page_id, lp.id
  end
end
