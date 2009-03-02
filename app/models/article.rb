class Article < ScamperBase
  #establish_connection
  has_many :placements
  has_many :pages, :through => :placements
  has_one :primary_page, :through => :placements, :conditions => [ "canonical = ?", true ], :class_name => "Page", :source => :page

  liquid_methods :title, :subtitle, :blurb, :body_html, :published_at

  def body_html
    bh = read_attribute :body_html
    return bh if bh && !bh.blank?
    body
  end
end
