class Site < ScamperBase
  #establish_connection
  belongs_to :landing_page, :class_name => 'Page'
  liquid_methods :name
end
