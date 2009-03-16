class MediaController < ApplicationController
  make_resourceful do
    actions :all
  end
  def index
    @media = Media.paginate :page => params[:page], :per_page => 40
    respond_to do |format|
      format.html {}
      format.js do
        render :json => @media.to_json(:methods => [ :micro_path, :thumb_path ])
      end
    end
  end

end
