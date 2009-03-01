class LegacyNav < LegacyData
  set_table_name 'navtbl'
  set_inheritance_column "legacy_type"
  cattr_accessor :callbacks, :import_to_class
  import_to :article

  after_import :place_in_layout
  
  IMPORT_KEYS = {
    :article => {
      :subtitle => :name,
      :title => :titletext,
      :legacy_type => 'nav',
      :legacy_id => :id,
      :body => :describe_nav
    }
  }

  def place_in_layout
    locations = LegacyNavLocation.find_all_by_navid id
    locations.each do |loc|
      next unless loc.layout_id and loc.position
      loc_nav_side = loc.position =~ /l/i ? 'nav_layout_left' : 'nav_layout_right'
      layout_page = Page.find_by_legacy_id_and_legacy_type loc.layout_id, loc_nav_side
      next unless layout_page
      layout_page.placements.create :article_id => imported.id, :list_order => loc.position[ /(\d+)/, 1 ]
    end
  end

  def describe_nav
    body = ''
    body += nosqlcode if nosqlcode && !nosqlcode.blank?
    body += "SQL: #{sql_statement}\n\n" if sql_statement && !sql_statement.blank?
    body += "PHP include #{include_file}, calls #{include_function} and says \n #{include_function_args}\n" if include_file and !include_file.blank?
    body += "Morelink: #{mfile}\n" if mfile
    body += "Link results to ( article.php or #{linkfile} )\n" if linkfile
    body += "Request var: ( id || #{mvar1} )\n" if mvar1
    body += "Request var: ( typeid || #{mcall2} )\n" if mcall1
    body += "Limit results to: ( 20 || #{list_limit} )\n" if list_limit
    body += "Title Image: #{titleimg}" if titleimg
    body
  end

end
