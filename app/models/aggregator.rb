class Aggregator < ScamperBase
  belongs_to :page
  has_many :sources,      :class_name => 'AggregationSource'
  has_many :source_pages, :through => :sources, :source => :page

  def update_page
    included_placements = if logic =~ /match_all/
      Placement.content.on_all_pages( source_pages )
    else
      Placement.content.on_pages( source_pages )
    end

    included_placements.each do |pl|
      next if page.placements.content.visible.find_by_child_item_id_and_child_item_type  pl.child_item_id, pl.child_item_type
      page.placements.create pl.attributes.merge( :assigned_order => nil, :list_order => nil, :view_type => 'list/default' )
    end
  end
end
