class PagesController < ApplicationController
  layout "administration", :only => [ :edit, :new ]

  make_resourceful do
    actions :all
  end

  helper_method :render_to_string

  def show

    @page = Page.find params[:id]
    Liquid::Template.register_tag('layout_area', LayoutAreaTag)
    Liquid::Template.register_tag('custom_block', CustomBlockTag)
    Liquid::Template.register_tag('place', PlaceTag)
    xtemplate = Liquid::Template.parse( @page.page_layout.html )
    page_html = xtemplate.render!( { 'page' => @page, 'current_page' => @page , 'site' => current_site } , :registers => { :controller => self } ) 
    render :text => page_html

  end

end
