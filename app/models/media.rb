class Media < ActiveRecord::Base
  has_attached_file :image, :styles => { :thumb => "100x100>", :medium => "200x300>" }
end
