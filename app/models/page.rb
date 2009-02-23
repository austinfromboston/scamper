class Page < ScamperBase
  establish_connection
  has_many :placements
  has_many :articles, :through => :placements
  has_one :primary_article, :through => :placements, :conditions => [ 'canonical = ?', true], :class_name => "Article", :source => :article
  belongs_to :parent_page, :class_name => "Page"
end
