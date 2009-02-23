class ScamperBase < ActiveRecord::Base
  establish_connection 
  @abstract_class = true
end
