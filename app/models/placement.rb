class Placement < ScamperBase
  belongs_to :page
  belongs_to :article
  belongs_to :child_page, :class_name => 'Page'
  named_scope :ordered, :order => 'list_order'

  liquid_methods :content, :display, :list_order, :block, :article, :child_page, :article_id, :child_page_id

  def content
    article || child_page
  end
end
