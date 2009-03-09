class Aggregator < ScamperBase
  belongs_to :page
  has_many :sources,      :class_name => 'AggregationSource'
  has_many :source_pages, :through => :sources, :source => :page

  def update_page
    Placement.content.on_pages( source_pages ).each do |pl|
      next if page.placements.find_by_child_item_id_and_child_item_type  pl.child_item_id, pl.child_item_type
      page.placements.create pl.attributes
    end
  end
end
