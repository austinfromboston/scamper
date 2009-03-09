class Page < ScamperBase
  has_many :placements, :order => 'list_order'

  has_many :articles, :through => :placements, :source => :child_item, :source_type => 'Article', :conditions => [ "placements.block is ?", nil ]
  has_one :primary_article, :through => :placements, :conditions => [ 'canonical = ?', true], :source => :child_item, :source_type => 'Article'


  has_many :media, :through => :placements, :source => :child_item, :source_type => 'Media'
  has_one :primary_media, :through => :placements, :conditions => [ 'canonical = ?', true], :source => :child_item, :source_type => 'Media'
  has_many :included_pages, :through => :placements, :source => :child_item, :source_type => 'Page'
  belongs_to :parent_page, :class_name => "Page"
  has_many :child_pages, :class_name => "Page", :foreign_key => "parent_page_id", :order => 'tree_order'

  belongs_to :page_layout
  has_friendly_id :tag

  has_many :aggregation_sources
  has_many :listening_aggregators, :through => :aggregation_sources, :source => :aggregator
  has_one :aggregator

  liquid_methods :name, :url, :tag, :parent_page, :metakeywords, :metadescription, :id, :placements

  def descendents
    child_pages.inject(child_pages) do |all_pages, page|
      all_pages << page.child_pages.map { |p| p.descendents }
    end.flatten.uniq
  end

  def ancestors
    return [] unless parent_page
    parent_page.ancestors.unshift parent_page
  end

  def landing_page?
    Site.find_by_landing_page_id id
  end

  def to_param
    ( tag and !tag.blank? and tag ) or id.to_s
  end


end
