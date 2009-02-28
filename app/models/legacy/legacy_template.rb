class LegacyTemplate < LegacyData
  set_table_name 'template'
  cattr_accessor :callbacks, :import_to_class
  set_inheritance_column "legacy_type"
  import_to :page_layout

  IMPORT_KEYS = {
    :page_layout => {
      :html => :import_template,
      :name => :name,
      :legacy_id => :id
    },
    :nav => {
      :html => :nav_template,
      :name => "default nav block"
    }
  }

  def import_template
    import_header + ( default_body % convert_urls( convert_tokens(header2)) )
  end

  def convert_tokens(source)
    source.gsub(  /(\{\{|<\?php)([^\}>]+)(\}\}|\?>)/, '<div class="import-token">PHP: \2</div>' ).
      gsub(/\[-body-\]/, "{{body}}" ).
      gsub(/\[-left nav-\]/, "{{blocks['left']}}").
      gsub( /\[-right nav-\]/, "{{blocks['right']}}" )
  end

  def convert_urls(source)
    source.gsub( /src=\s*(["'])(img|custom|scripts)/, 'src=\1/legacy/\2' )
  end

  def default_body
    "%s"
  end

  def import_header
    default_header % convert_urls(extra_header)
  end

  def default_header
    "<head>#{LEGACY_HEADER}%s</head>"
  end

  LEGACY_HEADER = <<-HEADER
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" type="text/css" href="/legacy/styles_default.css" id="default">

<link rel="stylesheet" type="text/css" href="/legacy/custom/styles.css">
<style type='text/css'>
img.thumb {
    border:0;
    width: 101px;
    max-height: 300px;
}</style>
<script language="Javascript"  type="text/javascript" src="/legacy/scripts/functions.js"></script>
HEADER

  def import_nav
    layout = PageLayout.find_by_name "default nav block"
    layout ||= PageLayout.create local_attributes( :nav )
    layout
  end

  def nav_template
    LEGACY_NAV
  end

  LEGACY_NAV = <<-NAV
<div class="nav_block" id="block_{{block_name}}">
{% for placement in placements %}
  <div class="nav_position_{{forloop.index}}">
    {{ placement | display }}
  </div>
{% endfor %}
</div>
NAV


end
