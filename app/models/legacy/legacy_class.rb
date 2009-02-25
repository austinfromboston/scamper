class LegacyClass < LegacyData
  set_table_name 'class'
  set_inheritance_column "legacy_type"
  cattr_accessor :callbacks, :import_to_class
  import_to :page
  
  IMPORT_KEYS = {
    :page => {
      :tag => :simple_name,
      :name => :amp_class
  }
  }
  def simple_name
    simplify_tag amp_class
  end
end
