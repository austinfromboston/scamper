class Article < ScamperBase
  #establish_connection
  has_many :placements
  has_many :pages, :through => :placements
  has_one :primary_page, :through => :placements, :conditions => [ "canonical = ?", true ], :class_name => "Page", :source => :page

  named_scope :on_page, lambda { |page| 
    { :conditions => [ "articles.id in (?)", Placement.find_all_by_page_id( page.id ).map(&:article_id) ] } 
  }
  named_scope :public, :conditions => [ "articles.status = ?", 'live' ]

  liquid_methods :title, :subtitle, :blurb, :body_html, :published_at

  def body_html
    bh = read_attribute :body_html
    return bh if bh && !bh.blank?
    body
  end
end
