class LegacyNavLocation < LegacyData
  set_table_name 'nav'
  set_inheritance_column "legacy_type"
  cattr_accessor :callbacks, :import_to_class
end
