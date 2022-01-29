# frozen_string_literal: true

module ApplicationHelper
  def browser_title
    title = @browser_title || page_title
    "#{title ? "#{title} | " : nil}#{Rails.application.name}"
  end

  def set_browser_title(value)
    @browser_title = value
  end

  def set_page_title(title)
    @page_title = title
  end

  def page_title
    @page_title
  end

  def guest_user?
    !current_user
  end

  def prepare_alerts_base
    js = []
    js << ['success', message_for_item(flash[:notice], :notice_item)] unless flash[:notice].blank?
    js << ['error', message_for_item(flash[:errors], :errors_itme)] unless flash[:errors].blank?
    js
  end

  def flash_messages
    javascript_tag "window.alerts=#{prepare_alerts_base.to_json};"
  end

  def admin_authorized?
    can?(:manage, User)
  end

  # Renders form using readonly, display-friendly view.
  def view_for(record, options = {}, &block)
    raise ArgumentError, 'Missing block' unless block_given?

    html_options = options[:html] ||= {}
    html_options[:class] = (html_options[:class] || '').strip << ' readonly-form'

    case record
    when String, Symbol
      object_name = record
      object      = nil
    else
      object      = record.is_a?(Array) ? record.last : record
      object_name = model_name_from_record_or_class(object).param_key
    end
    builder = FormViewBuilder.new(object_name, object, self, options)
    output  = capture(builder, &block)

    content_tag(:div, html_options) { output }
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      raw message % link_to(*item)
    else
      message % item
    end
  end

  def yes_or_no(value)
    value ? 'Yes' : '' # 'No'
  end

  def error_messages_for(*objects)
    options = objects.extract_options!
    options[:header_message] ||= I18n.t(:"activerecord.errors.header", default: 'Invalid Fields')
    options[:message] ||= I18n.t(:"activerecord.errors.message", default: 'Correct the following errors and try again.')
    messages = objects.compact.map { |o| o.errors.full_messages }.flatten
    return if messages.empty?

    content_tag(:div, class: 'error_messages') do
      list_items = messages.map { |msg| content_tag(:li, msg) }
      content_tag(:h2, options[:header_message]) + content_tag(:p, options[:message]) + content_tag(:ul, list_items.join.html_safe)
    end
  end

  def picture_tag(photo: nil, style: 'quarter', img_class: 'img-thumb')
    render 'shared/picture', id: photo.id, style: style, alt_text: photo.caption, img_class: img_class
  end

  def checkbox_button(label, attr, checked)
    render 'shared/checkbox_button',
           active_class: checked ? 'active' : '',
           attr: attr,
           label_text: label,
           checked: checked
  end

  def table(attrs={}, &block)
    attrs['data-sortable'] = true if attrs.delete(:sortable)
    content_tag :table, capture(&block), attrs.merge(class: 'table table-striped table-condensed')
  end

  def link_to_building(building)
    return 'Unhoused' if building.blank?

    link_to(building.street_address.gsub("\n", '<br />').html_safe, building)
  end

  def birthday(record)
    return record.birth_year || 'unknown' if record.birth_month.blank?

    "#{Date::MONTHNAMES[record.birth_month]} #{record.birth_year}"
  end
end

SimpleForm::FormBuilder.class_eval do
  def editing?
    true
  end

  def viewing?
    false
  end
end
