class Placement < ActiveRecord::Base
  establish_connection
  belongs_to :page
  belongs_to :article
end
