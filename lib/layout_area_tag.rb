class LayoutAreaTag < Liquid::Tag
  include LiquidExtensions::Helpers
  attr_accessor :block_name

  def initialize( tag_name, block_name, tokens )
    block_name.gsub!(/[" ]/, '') 
    self.block_name = block_name unless block_name.empty?
    super
  end

  def render(context)

    placements = context.scopes.last['page'].placements.ordered.find_all_by_block block_name
    placements.inject("") do |text, pl|
      if pl.child_page
        layout_area_layout = Liquid::Template.parse( pl.child_page.page_layout.html )
        text << layout_area_layout.render!( { 'page' => pl.child_page, 'current_page' => context.scopes.last['page'] }, { :registers => context.registers } )
      elsif pl.article
        view_type = pl.view_type || 'default'
        text << render_erb( context, "articles/#{view_type}", { :article => pl.article, :current_page => context.scopes.last['current_page'] } )
      end
      text
    end
  end

end
