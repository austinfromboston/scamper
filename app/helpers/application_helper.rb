# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def layout_area( page, block_name = nil )
    Placement.ordered.find_all_by_page_id_and_block( page['id'], block_name ).inject("") do | rendered_area, placement |
      rendered_area << display_placement( placement )
    end
  end

  def display_page( page )
    if page.page_layout
      page_template = Liquid::Template.parse page.page_layout.html
      return page_template.render 'page' => page
    end
    return display_article( page.primary_article ) if page.primary_article
    "page render failszz!1!"
  end

  def display_placement( placement )
    return display_page( placement.child_page ) if placement.child_page
    #if placement.display
    display_article placement.article
  end

  def display_article( art )
    #@article = art
    template = "
<div class='display_article'>
<h1 class='title'>#{art.title}</h1>
<div class='subtitle'>#{art.subtitle}</div>
<div class='body'>#{art.body_html}</div>
</div>"
    template
  end
end
