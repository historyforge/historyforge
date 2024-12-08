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

  def prepare_alerts
    js = []
    js << ['success', message_for_item(flash[:notice], :notice_item)] if flash[:notice].present?
    js << ['error', message_for_item(flash[:errors], :errors_item)] if flash[:errors].present?
    js << ['alert', message_for_item(flash[:alert], :alert_item)] if flash[:alert].present?
    js
  end

  def flash_messages
    javascript_tag "window.alerts=#{prepare_alerts.to_json};"
  end

  def admin_authorized?
    can?(:manage, User)
  end

  def google_tag_manager
    return unless Rails.env.production? && ENV['GOOGLE_ANALYTICS']

    <<~HTML.html_safe
      <!-- Google Tag Manager -->
      <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
      new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
      j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
      'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
      })(window,document,'script','dataLayer','#{AppConfig[:google_analytics]}');</script>
      <!-- End Google Tag Manager -->
    HTML
  end

  # Renders form using readonly, display-friendly view.
  def view_for(record, options = {}, &)
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
    output  = capture(builder, &)

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

  def table(attrs={}, &)
    attrs['data-sortable'] = true if attrs.delete(:sortable)
    content_tag :table, capture(&), attrs.merge(class: 'table table-striped table-condensed table-responsive')
  end

  def link_to_building(building)
    return 'Unhoused' if building.blank?

    link_to(building.street_address.gsub("\n", '<br />').html_safe, building)
  end

  def birthday(record)
    return record.birth_year || 'unknown' if record.birth_month.blank?

    "#{Date::MONTHNAMES[record.birth_month]} #{record.birth_year}"
  end

  def page_entries_info(collection, entry_name: nil)
    entry_name = if entry_name
                   entry_name.pluralize(collection.size, I18n.locale)
                 else
                   collection.entry_name(count: collection.size).downcase
                 end

    if collection.total_pages < 2
      t('helpers.page_entries_info.one_page.display_entries', entry_name: entry_name, count: collection.total_count)
    else
      from = collection.offset_value + 1
      to   = collection.offset_value + (collection.respond_to?(:records) ? collection.records : collection.to_a).size
      total = ActiveSupport::NumberHelper::NumberToDelimitedConverter.convert(collection.total_count, delimiter: ',')
      t('helpers.page_entries_info.more_pages.display_entries', entry_name: entry_name, first: from, last: to, total:)
    end.html_safe
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
