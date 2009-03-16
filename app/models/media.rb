class Media < ActiveRecord::Base
  has_many :placements, :as => :child_item, :dependent => :destroy
  has_many :pages, :through => :placements

  has_attached_file :image, :styles => { :micro => "24x24>", :thumb => "100x100>", :medium => "200x300>"  }
  def name
    image.original_filename
  end

  def micro_path
    image.url(:micro)
  end
  def thumb_path
    image.url(:thumb)
  end
end
