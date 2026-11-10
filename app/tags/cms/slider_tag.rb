# frozen_string_literal: true

module Cms
  class SliderTag < Liquid::Block
    def initialize(tag_name, markup, tokens)
      id, *options = markup.split
      @css_id = id.presence || 'slider'
      @options = options.filter_map do |option|
        key, value = option.split(':', 2)
        [key, value.delete(%q{'"})] if value
      end.to_h
      super
    end

    def render(context)
      options = ERB::Util.html_escape(@options.to_json)
      id = ERB::Util.html_escape(css_id)
      %(<div id="#{id}" class="carousel slide" data-controller="cms-slider" data-action="turbo:before-cache@document->cms-slider#disconnect" data-slider-options="#{options}"><div class="carousel-inner">#{super}</div></div>)
    end

    attr_reader :css_id
  end
end
