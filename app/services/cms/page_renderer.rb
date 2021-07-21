module Cms
  class PageRenderer

    class_attribute :compiled_templates
    self.compiled_templates ||= {}

    def self.run(page, template, *args)
      new(page, template, *args).run
    end

    def initialize(page, template, *args)
      @page, @template = page, template
      @optional_vars = args.extract_options!
      @optional_vars.stringify_keys!
    end

    def run
      guts = compiled_template.render template_vars
      if guts =~ /\{\{/
        liquid_guts = Liquid::Template.parse guts
        guts = liquid_guts.render template_vars
      end
      css_id = page.css_id.present? ? page.css_id : "page_#{page.id}"
      css_class = page.css_class.present? ? page.css_class : "page_#{page.id}"

      html_options = {}
      html_options['id'] = css_id
      html_options['class'] = css_class

      template.content_tag :div, guts.html_safe, html_options
      # html = template.content_tag(:style, page.css_compiled.html_safe, type: 'text/css') + html if page.css_compiled.present?

      # html
    end

    def self.expire(page)
      compiled_templates[page.url_path] = nil
    end

    private

    attr_accessor :page, :template, :optional_vars

    def compiled_template
      compiled_templates[page.url_path] || begin
        compiled_templates[page.url_path] = Liquid::Template.parse(page.template)
      end
    end

    def compiled_templates
      self.class.compiled_templates
    end

    def template_vars
      @template_vars || begin
        @template_vars = optional_vars.dup
        @template_vars.merge! page_widget_template_vars
        @template_vars.merge! parts_from_view_template
        @template_vars
      end
    end

    def page_widget_template_vars
      page.widgets.inject({}) { |hash, widget|
        callback = widget.access_callback
        if callback.blank? || !template.respond_to?(callback) || template.send(callback)
          hash[widget.name] = widget.cached_html
        end
        hash
      }
    end

    # TODO: if we have some and they aren't saved to the page's dummy_vars, we should do that here
    # TODO: how to update dummar_vars?
    # TODO: if the page has a controller and action and we aren't on it, then fill in sections from dummy_vars
    def parts_from_view_template
      sections = template.cms_page_sections
      if page.controller && page.action
        if sections.present? && !page.dummy_vars?
          sections.each do |name, content|
            section = page.build_dummy_var
            section.name = name
            section.content = content
          end
          page.data_will_change!
          page.save
        elsif page.dummy_vars? && sections.blank? && template.can?(:update, Cms::Page)
          page.dummy_vars.each do |section|
            sections[section.name] = section.content
          end
        end
      end
      sections.stringify_keys
    end

  end
end
