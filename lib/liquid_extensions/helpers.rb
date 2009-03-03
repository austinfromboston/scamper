module LiquidExtensions
  module Helpers

    def render_erb(context, file_name, locals)
      context.registers[:controller].__send__(:render_to_string, :partial => file_name, :locals => locals)
    end
  end
end
