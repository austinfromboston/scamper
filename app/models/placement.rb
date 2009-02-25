class Placement < ScamperBase
  belongs_to :page
  belongs_to :article
  belongs_to :child_page, :class_name => 'Page'
end
