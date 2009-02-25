class Page < ScamperBase
  #establish_connection
  has_many :placements
  has_many :articles, :through => :placements, :conditions => [ "placements.article_id is not ?", nil ]
  has_one :primary_article, :through => :placements, :conditions => [ 'canonical = ?', true], :class_name => "Article", :source => :article

  has_many :child_pages, :through => :placements, :source => :child_page, :conditions => [ "child_page_id is not ?" , nil ]
  has_many :parent_placements, :class_name => "Placement", :foreign_key => 'child_page_id'
  has_many :parent_pages, :through => :parent_placements, :source => :page
  #belongs_to :parent_page, :class_name => "Page"
  #has_many :child_pages, :class_name => "Page", :foreign_key => "parent_page_id"
end
