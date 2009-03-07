class Placement < ScamperBase
  belongs_to :page
  belongs_to :child_item, :polymorphic => true
  #belongs_to :article
  #belongs_to :child_page, :class_name => 'Page'
  named_scope :ordered, :order => 'list_order'
  named_scope :articles, :conditions => [ "child_item_type = ?", "Article" ]
  named_scope :child_pages, :conditions => [ "child_item_type = ?", "Page" ]
  named_scope :images, :conditions => [ "child_item_type = ?", "Media" ]

  liquid_methods :content, :view_type, :list_order, :block, :article, :child_item #, :article_id, :child_page_id

  def content
    article || child_page
  end

end
