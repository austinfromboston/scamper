class PagesController < ApplicationController
  make_resourceful do
    #actions :all
  end

  helper_method :render_to_string
  def show

=begin
    blocks = [ 'left', 'right' ] 
    r_blocks = Hash[ *blocks.map do |bloc|
      placement = @page.placements.find_all_by_block bloc
      block_template = Liquid::Template.parse( placement.child_page.page_layout.html )
      [ bloc, "#{bloc.upcase}: #{block_template.render( 'placements' => placement.child_page.placements.ordered, 'block_name' => bloc )}" ]
    end.flatten ]
=end
=begin
    cx = self
    render_helper = Module.new do
      def render_to_string(*args)
        cx.send :render_to_string, *args
      end
    end
    #Liquid::Template.register_filter(render_helper)
=end

    @page = Page.find params[:id]
    #Liquid::Template.register_filter(ApplicationHelper)
    Liquid::Template.register_tag('layout_area', LayoutAreaTag)
    Liquid::Template.register_tag('custom_block', CustomBlockTag)
    Liquid::Template.register_tag('place', PlaceTag)
    xtemplate = Liquid::Template.parse( @page.page_layout.html )
    page_html = xtemplate.render!( { 'page' => @page, 'current_page' => @page , 'site' => current_site } , :registers => { :controller => self } ) 
    render :text => page_html

      #{ 'blocks' => 
      #{ 'body'  => @page.primary_article.body_html }.merge( rendered_blocks ) }, 
      #  :filters => [ApplicationHelper] )
  end

  def current_site
    Site.first
  end
end
