class LegacyTemplate < LegacyData
  set_table_name 'template'
  cattr_accessor :callbacks, :import_to_class
  set_inheritance_column "legacy_type"
  import_to :page_layout

  IMPORT_KEYS = {
    :placement => {
      :html => :import_template,
      :name => :name,
      :legacy_id => :id
    }
  }

  def import_template
    import_header + ( default_body % header2 )
  end

  def convert_body_tokens
    header2.gsub  /(\{\{|<\?php)([^\}>]+)(\}\}|\?>)/, '<div class="import-token">The following is PHP: \1</div>'
  end

  def default_body
    "<body>%s</body>"
  end
  def import_header
    default_header % extra_header
  end
  def default_header
    "<head>%s</head>"
  end

end
