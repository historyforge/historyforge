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
    js << ['log', message_for_item(flash[:alert], :alert_item)] unless flash[:alert].blank?
    js << ['log', message_for_item(flash[:warning], :warning_item)] unless flash[:warning].blank?
    js
  end

  def flash_messages
    javascript_tag "window.alerts=#{prepare_alerts_base.to_json};"
  end

  def prepare_xhr_alerts
    prepare_alerts_base.map { |key, value|
      content_tag(:div, value, :class => 'alert hidden', 'data-alert' => key)
    }.join('')
  end

  def admin_authorized?
    can?(:manage, User)
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
     raw message % link_to(*item)
    else
      message % item
    end
  end

  def strip_brackets(str)
    str ||=""
    str.gsub(/[\]\[()]/,"")
  end

  def yes_or_no(value)
    value ? 'Yes' : '' # 'No'
  end

  def snippet(thought, wordcount)
    if thought
      thought.split[0..(wordcount-1)].join(" ") +(thought.split.size > wordcount ? "..." : "")
    end
  end

  def error_messages_for(*objects)
    options = objects.extract_options!
    options[:header_message] ||= I18n.t(:"activerecord.errors.header", :default => "Invalid Fields")
    options[:message] ||= I18n.t(:"activerecord.errors.message", :default => "Correct the following errors and try again.")
    messages = objects.compact.map { |o| o.errors.full_messages }.flatten
    unless messages.empty?
      content_tag(:div, :class => "error_messages") do
        list_items = messages.map { |msg| content_tag(:li, msg) }
        content_tag(:h2, options[:header_message]) + content_tag(:p, options[:message]) + content_tag(:ul, list_items.join.html_safe)
      end
    end
  end

  def assets(directory)
    assets = {}

    Rails.application.assets.index.each_logical_path("#{directory}/*") do |path|
      assets[path.sub(/^#{directory}\//, "")] = asset_path(path)
    end

    assets
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

  def panel(title=nil, *args, &block)
    options = args.extract_options!
    options.reverse_merge! open: true, removable: false
    form = options[:form]
    tools = options[:tools]
    tools = tools.html_safe if tools.present?
    panel_class = options[:class] || 'card-default'
    heading = ''.html_safe
    extra_body = ''.html_safe

    if title
      if options[:removable]
        extra_body << form.hidden_field(:_destroy) if form
        remove_button = content_tag(:button, "&times;".html_safe, class: 'remove pull-right btn btn-default btn-sm', type: 'button', title: 'Remove', 'data-toggle' => 'tooltip')
      else
        remove_button = ''.html_safe
      end
      title = content_tag :span, title
      if form && options[:input]
        title << form.text_field(options[:input], placeholder: options[:input].to_s.humanize)
      end

      panel_title_options = { class: 'card-title' }
      panel_body_options = { class: 'card-body' }
      if options[:collapsible] || options[:collapse]
        id = SecureRandom.uuid
        panel_title_options['data-toggle'] = 'collapse'
        panel_title_options['data-target'] = "##{id}"
        panel_body_options[:class] << ' card-collapse'
        panel_body_options[:id] = id
        if options[:open]
          panel_body_options[:class] << ' in'
        else
          panel_title_options[:class] << ' collapsed'
          panel_body_options[:class] << ' collapse'
          panel_body_options[:style] = 'height:0px;'
        end
      end

      heading = title ? content_tag(:div, remove_button + content_tag(:h4, title, panel_title_options) + content_tag(:div, tools, class: 'tools'), class: 'card-header') : nil
    end
    body    = content_tag(:div, extra_body + capture(&block), panel_body_options)
    content_tag :div, heading + body, class: "card #{panel_class} mb-3"
  end

  def census_card_edit(title: nil, list: nil)
    header = title && content_tag(:div, title, class: 'card-header')

    slider = content_tag :div, list.join('').html_safe, class: 'census-slider vertical'
    wrapped_slider = content_tag :div, slider, class: 'census-slider-wrapper'
    body = content_tag :div, wrapped_slider, class: 'card-body'
    content_tag(:div, header + body, class: 'card mb-3')
  end

  def census_card_show(title: nil, list: nil)
    header = title && content_tag(:div, title, class: 'card-header')
    body = content_tag(
      :ul,
      list.map { |item| content_tag(:li, item, class: 'list-group-item')}.join('').html_safe,
      class: 'list-group list-group-flush'
    )
    content_tag(:div, header + body, class: 'card mb-3')
  end

  def table(attrs={}, &block)
    attrs['data-sortable'] = true if attrs.delete(:sortable)
    content_tag :table, capture(&block), attrs.merge(:class => 'table table-striped table-condensed')
  end

  def link_to_building(building)
    return 'Unhoused' if building.blank?

    link_to(building.street_address.gsub("\n", "<br />").html_safe, building, target: :_blank)
  end

  def birthday(record)
    return record.birth_year || 'unknown' if record.birth_month.blank?

    "#{Date::MONTHNAMES[record.birth_month]} #{record.birth_year}"
  end
end
