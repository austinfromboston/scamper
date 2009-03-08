class Media < ActiveRecord::Base
  has_many :placements, :as => :child_item
  has_many :pages, :through => :placements

  has_attached_file :image, :styles => { :thumb => "100x100>", :medium => "200x300>" }
end
