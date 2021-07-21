module Cms
  class SliderTag < Liquid::Block

    def initialize(tag_name, markup, tokens)
      @slider_options = "{selector: \".slides > .cms-slide\""
      if markup.present?
        options = markup.split(' ')
        @css_id = options.shift
        options.each do |option|
          @slider_options << ', ' << option.sub(/\:/, ': ')
        end
      else
        @css_id = 'slider'
      end
      @slider_options << "}"
      super
    end

    def render(context)
      return <<-EOD
      <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/flexslider/2.6.0/jquery.flexslider.min.js"></script>
      <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/flexslider/2.6.0/flexslider.min.css">
      <div id="#{css_id}" class="flexslider"><div class="slides">#{super}</div></div>
      <script type="text/javascript">
        $("##{css_id}").flexslider(#{@slider_options.html_safe});
      </script>
      EOD
    end

    attr_reader :css_id

  end
end

Liquid::Template.register_tag('slider', Cms::SliderTag)
