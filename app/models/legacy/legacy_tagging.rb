class LegacyTagging < LegacyData
  set_table_name 'tags_items'
  set_inheritance_column "legacy_type"
  cattr_accessor :callbacks, :import_to_class
end
