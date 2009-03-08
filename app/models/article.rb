class Article < ScamperBase
  #establish_connection
  has_many :placements, :as => :child_item
  has_many :pages, :through => :placements
  has_one :primary_page, :through => :placements, :conditions => [ "canonical = ?", true ], :class_name => "Page", :source => :page
  has_one :primary_placement, :conditions => [ "canonical = ?", true ], :class_name => "Placement", :as => :child_item

  named_scope :on_page, lambda { |page| 
    { :conditions => [ "articles.id in (?)", page.article_ids ] }
  }
  named_scope :public, :conditions => [ "articles.status = ?", 'live' ]

  liquid_methods :title, :subtitle, :blurb, :body_html, :published_at

  def body_html
    bh = read_attribute :body_html
    return bh if bh && !bh.blank?
    body
  end

  def primary_image
    primary_page && primary_page.primary_media && primary_page.primary_media.image
  end

  # means that the article lives only on a single page in addition to its canonical page
  def single_placement?
    primary_placement && placements.size < 3
  end
end
