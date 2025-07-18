# frozen_string_literal: true

module ItemNavigationHelper
  def previous_nav_link(path, text: 'Prev')
    content_for :pills do
      link_to path, class: 'btn btn-light' do
        content_tag(:i, '', class: 'fa fa-chevron-left') +
          content_tag(:span, " #{text}", class: 'd-none d-lg-inline')
      end
    end
  end

  def next_nav_link(path, text: 'Next')
    content_for :pills do
      link_to path, class: 'btn btn-light' do
        content_tag(:span, "#{text} ", class: 'd-none d-lg-inline') +
          content_tag(:i, '', class: 'fa fa-chevron-right')
      end
    end
  end
end
