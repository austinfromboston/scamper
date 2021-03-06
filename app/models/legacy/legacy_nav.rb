class LegacyNav < LegacyData
  set_table_name 'navtbl'
  set_inheritance_column "legacy_type"
  cattr_accessor :callbacks, :import_to_class
  import_to :article
  attr_accessor :placement_attrs

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

      layout_page.placements.create( {:child_item_id  => imported.id, 
                                      :list_order     => loc.position[ /(\d+)/, 1 ], 
                                      :assigned_order => loc.position[ /(\d+)/, 1 ], 
                                      :view_type      => 'nav', 
                                      :child_item_type => 'Article' }.merge( placement_attrs || {} ))
    end
  end

  def describe_nav
    body = ''
    body += nosqlcode if nosqlcode && !nosqlcode.blank?
    body += "SQL: #{sql_statement}<br><br>" if sql_statement && !sql_statement.blank?
    body += "PHP include #{include_file}<br>" if include_file and !include_file.blank?
    body += "include calls #{include_function}<br>" if include_function and !include_function.blank? 
    body += "include args says <br>#{include_function_args}<br>" if include_function_args and !include_function_args.blank? 
    body += "Morelink: #{mfile}<br>" if mfile and !mfile.blank?
    body += "Link results to ( article.php or #{linkfile} )<br>" if linkfile and !linkfile.blank?
    body += "Request var: ( id || #{mvar1} )<br>" if mvar1 and !mvar1.blank?
    body += "Request var: ( typeid || #{mcall2} )<br>" if mcall2 and !mcall2.blank?
    body += "Limit results to: ( 20 || #{list_limit} )<br>" if list_limit and !list_limit.blank?
    body += "Title Image: #{titleimg}<br>" if titleimg and !titleimg.blank?
    body += "RSS Feed: #{rss}<br>" if rss and !rss.blank?
    body += "Legacy nav: #{id}\n"
    body
  end

end
