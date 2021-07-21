module Cms
  class PanelTag < Liquid::Block
    def initialize(tag_name, markup, tokens)
       super
       @header = markup
    end

    def render(context)
      if @header
        "<div class=\"panel panel-default\"><div class=\"panel-heading\">#{@header}</div><div class=\"panel-body\">#{super}</div></div>"
      else
        "<div class=\"panel panel-default\"><div class=\"panel-body\">#{super}</div></div>"
      end
    end
  end
end

Liquid::Template.register_tag('panel', Cms::PanelTag)
