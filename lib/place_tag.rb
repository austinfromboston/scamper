class PlaceTag < Liquid::Tag
  include LiquidExtensions::Helpers
  attr_accessor :placement_var_name

  def initialize( tag_name, params, tokens )
    self.placement_var_name = params.gsub(/\s/, '')
    super
  end

  def render(context)
    self.placement_var_name ||= 'placement'
    placement = context.scopes[0][placement_var_name]
    view_type = placement.view_type || 'default'
    render_erb( context, "articles/#{view_type}", { :article => placement.article } )
  end

end
