module CmsHelper

  def page_text_fields(form)
    fields = new_child_fields(form, :widgets, object: Cms::Text.new, partial: 'text')
    content_for(:body_end) { content_tag(:script, fields, type: 'text/html', id: "new_text_fields") }
  end

  def page_audio_fields(form)
    fields = new_child_fields(form, :widgets, object: Cms::Audio.new, partial: 'audio')
    content_for(:body_end) { content_tag(:script, fields, type: 'text/html', id: "new_audio_fields") }
  end

  def page_embed_fields(form)
    fields = new_child_fields(form, :widgets, object: Cms::Embed.new, partial: 'embed')
    content_for(:body_end) { content_tag(:script, fields, type: 'text/html', id: "new_embed_fields") }
  end

  def page_picture_fields(form)
    fields = new_child_fields(form, :widgets, object: Cms::Picture.new, partial: 'picture')
    content_for(:body_end) { content_tag(:script, fields, type: 'text/html', id: "new_picture_fields") }
  end

  def page_document_fields(form)
    fields = new_child_fields(form, :widgets, object: Cms::Document.new, partial: 'document')
    content_for(:body_end) { content_tag(:script, fields, type: 'text/html', id: "new_document_fields") }
  end

  def page_testimonial_fields(form)
    fields = new_child_fields(form, :widgets, object: Cms::Testimonial.new, partial: 'testimonial')
    content_for(:body_end) { content_tag(:script, fields, type: 'text/html', id: "new_testimonial_fields") }
  end

  def cms_link
    return if cannot?(:manage, Cms::Page)
    ctrl = controller.class.name
    act = params[:action]
    if @page
      return if ctrl == 'Cms::PagesController' && act != 'show'
      link_to'Edit this Page', edit_cms_page_path(@page), class: 'dropdown-item'
    else
      return if ctrl.starts_with?('Cms')
      link_to'CMS this Page', new_cms_page_path(page: { title: page_title, url_path: request.path, controller: ctrl, action: act}), class: 'dropdown-item'
    end

  end

  def provide_cms_with(section, &block)
    @cms_page_sections ||= {}
    @cms_page_sections[section] = capture(&block)
  end

  def cms_page_sections
    @cms_page_sections || {}
  end

  def cms_body_class
    html = content_class || 'internal'
    if @page
      if @page.controller.present?
        html << " #{@page.controller}-#{@page.action}"
      else
        html << " #{controller_name}-#{action_name}"
      end
      if @page.title.present?
        html << " #{@page.title.downcase.dasherize}"
      end
    end
    html
  end
end
