class MediaController < ApplicationController
  make_resourceful do
    actions :all
  end
  def index
    @media = Media.all
  end

end
