class PagesController < ApplicationController
  make_resourceful do
    actions :all
  end
  def show
    @page = Page.find params[:id]
    @template = Liquid::Template.parse( PageLayout.find(3).html )
    @template.render 'body' => @page.primary_article.body_html, 'blocks' => { 'left' => "Left Nav Here", 'right' => "Right Nav Here" }
  end
end
