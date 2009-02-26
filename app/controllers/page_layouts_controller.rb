class PageLayoutsController < ApplicationController

  before_filter :find_page_layout

  PAGE_LAYOUTS_PER_PAGE = 20

  def create
    @page_layout = PageLayout.new(params[:page_layout])
    respond_to do |format|
      if @page_layout.save
        flash[:notice] = 'PageLayout was successfully created.'
        format.html { redirect_to @page_layout }
        format.xml  { render :xml => @page_layout, :status => :created, :location => @page_layout }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page_layout.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @page_layout.destroy
        flash[:notice] = 'PageLayout was successfully destroyed.'        
        format.html { redirect_to page_layouts_path }
        format.xml  { head :ok }
      else
        flash[:error] = 'PageLayout could not be destroyed.'
        format.html { redirect_to @page_layout }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @page_layouts = PageLayout.paginate(:page => params[:page], :per_page => PAGE_LAYOUTS_PER_PAGE)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @page_layouts }
    end
  end

  def edit
  end

  def new
    @page_layout = PageLayout.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @page_layout }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @page_layout }
    end
  end

  def update
    respond_to do |format|
      if @page_layout.update_attributes(params[:page_layout])
        flash[:notice] = 'PageLayout was successfully updated.'
        format.html { redirect_to @page_layout }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page_layout.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def find_page_layout
    @page_layout = PageLayout.find(params[:id]) if params[:id]
  end

end