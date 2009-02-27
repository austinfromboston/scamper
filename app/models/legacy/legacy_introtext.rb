class LegacyIntrotext < LegacyData
  set_table_name 'moduletext'
  set_inheritance_column 'legacy_type'
  AMP_FRONTPAGE = 2
end
