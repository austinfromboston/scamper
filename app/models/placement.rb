class Placement < ScamperBase
  belongs_to :page
  belongs_to :child_item, :polymorphic => true
  #belongs_to :article
  #belongs_to :child_page, :class_name => 'Page'
  named_scope :ordered, :order => 'list_order'

  named_scope :articles, :conditions => [ "child_item_type = ?", "Article" ]
  named_scope :child_pages, :conditions => [ "child_item_type = ?", "Page" ]
  named_scope :images, :conditions => [ "child_item_type = ?", "Media" ]

  named_scope :content, :conditions => [ "layout_area is ? and ( view_type != ? or view_type is ? )", nil, "header", nil ]
  named_scope :visible, :conditions => [ "( view_type != ? or view_type is ? )", "hidden", nil ]

  named_scope :on_pages, lambda { |pages| { :conditions => [ "page_id in (?)", pages ] } }
  named_scope :on_all_pages, lambda { |pages| 
    matching_criteria = Placement.items_on_all_pages( pages )
    if matching_criteria.empty?
      { :conditions => [ "? = ?", true, false ] }
    else
      condition_string = ( ["(child_item_id = ? and child_item_type = ?)"] * matching_criteria.size ).join( " OR " )
      { :conditions => [ condition_string, *matching_criteria.flatten ] }
    end
  }

  acts_as_list :column => "list_order", :scope => [ :page_id, :layout_area ], :default_position => :discover_list_placement

  liquid_methods :content, :view_type, :list_order, :layout_area, :article, :child_item #, :article_id, :child_page_id
  after_save :notify_aggregators

  def content
    article || child_page
  end

  after_create :update_page_placements_count
  after_destroy :update_page_placements_count
  def update_page_placements_count
    page.update_attribute :placements_count, page.placements.content.count
  end


  def self.items_on_all_pages(pages)
    pages.inject(nil) do |children, p|
      p_children = p.placements.content.map { |pl| [ pl.child_item_id, pl.child_item_type ] }
      children ||= p_children
      children & p_children
    end

  end

  def notify_aggregators
    page.listening_aggregators.each { |agg| agg.update_page } if page
  end

  def item_to_displace

=begin
    page.placements.content.visible.first :joins => "left join articles on articles.id = placements.child_item_id and placements.child_item_type = 'Article'", :conditions => [ "articles.published_at is not ? and articles.published_at < ? and placements.assigned_order is ?", nil, child_item.published_at, nil ], :order => 'articles.published_at DESC'
=end
      page.placements.content.visible.select do |pl|
        pl.child_item.is_a?(Article) and pl.child_item.published_at < child_item.published_at and pl.assigned_order.nil?
      end.max do |pl1, pl2| 
        pl1.child_item.published_at <=> pl2.child_item.published_at 
      end
  end

  def discover_list_placement
    return if view_type == 'hidden' && assigned_order.nil?
    my_new_position ||= assigned_order
    my_new_position ||= 1 if view_type == 'header'

    if my_new_position.nil? and child_item.is_a?(Article) and child_item.published_at.present?

      my_new_position = item_to_displace.list_order if item_to_displace 
    end

    if my_new_position
      increment_positions_on_lower_items( my_new_position )
      self.list_order = my_new_position
    else
      add_to_list_bottom
    end

  end

  def assigned?
    assigned_order && !assigned_order.zero?
  end

end
