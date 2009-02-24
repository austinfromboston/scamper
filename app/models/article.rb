class Article < ScamperBase
  #establish_connection
  has_many :placements
  has_many :pages, :through => :placements
  has_one :primary_page, :through => :placements, :conditions => [ "canonical = ?", true ], :class_name => "Page", :source => :page
end
