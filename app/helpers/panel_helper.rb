module PanelHelper
  def panel(title = nil, &block)
    heading = title ? panel_header(title) : nil
    body = panel_body(capture(&block))
    content_tag :div, heading + body, class: 'card card-default mb-3'
  end

  def panel_header(title)
    content_tag(:div, content_tag(:h5, title, class: 'card-title'), class: 'card-header')
  end

  def panel_body(body)
    content_tag(:div, body, class: 'card-body')
  end
end
