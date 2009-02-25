class LegacyTag < LegacyData
  set_inheritance_column "legacy_type"
  set_table_name 'tags'
  cattr_accessor :callbacks, :import_to_class
end
