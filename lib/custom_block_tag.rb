class CustomBlockTag < Liquid::Tag
  include LiquidExtensions::Helpers
  attr_accessor :block_name

  def initialize( tag_name, block_name, tokens )
    block_name.gsub!(/[" ]/, '') 
    self.block_name = block_name unless block_name.empty?
    super
  end

  def render(context)
    render_erb( context, "custom_blocks/#{block_name}", { :current_page => context.scopes.last['current_page'] } )
    rescue ActionView::MissingTemplate
     "Can't find custom_blocks/#{block_name}"
  end

end
