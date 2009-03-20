class LayoutAreaTag < Liquid::Tag
  include LiquidExtensions::Helpers
  attr_accessor :block_name

  def initialize( tag_name, block_name, tokens )
    block_name.gsub!(/[" ]/, '') 
    self.block_name = block_name unless block_name.empty?
    super
  end

  def render(context)

    placements = context.scopes.last['page'].placements.ordered.find_all_by_layout_area block_name
    placements.inject("") do |text, pl|
      if pl.child_item
        if pl.child_item.is_a? Page
          layout_area_layout = Liquid::Template.parse( pl.child_item.page_layout.html )
          text << layout_area_layout.render!( { 'page' => pl.child_item, 'current_page' => context.scopes.last['page'] }, { :registers => context.registers } )
        elsif pl.child_item.is_a? Article
          view_type = pl.view_type || 'default'
          text << render_erb( context, "articles/#{view_type}", { :article => pl.child_item, :current_page => context.scopes.last['current_page'] } )
        elsif pl.child_item.is_a? Media
          view_type = pl.view_type || 'default'
          text << render_erb( context, "media/#{view_type}", { :media => pl.child_item, :current_page => context.scopes.last['current_page'] } )
        end
      end
      text
    end
  end

end
