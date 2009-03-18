class ArticlesController < ApplicationController
  layout nil
  make_resourceful do
    actions :all
  end

  def current_objects
    if params[:q]
      Article.paginate :per_page => 20, :page => params[:page], :conditions => [ 'title like ? or blurb like ? or body like ?', "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%" ]
    else
      Article.paginate :per_page => 20, :page => params[:page]
    end
  end
end
