# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CMS sliders" do
  scenario "an existing Liquid slider supports arrows and indicators without jQuery", :js do
    cms_page = Cms::Page.create!(title: "Slider", url_path: "/slider-test", template: <<~HTML)
      {% slider photographs animation:"slide" slideshow:false %}
        <div class="cms-slide">The canal</div>
        <div class="cms-slide">The railway</div>
      {% endslider %}
    HTML
    visit cms_page_path(cms_page)

    expect(page).to have_css(".carousel-item.active", text: "The canal")
    find('button[aria-label="Next slide"]').click
    expect(page).to have_css(".carousel-item.active", text: "The railway")
    find('button[aria-label="Slide 1"]').click
    expect(page).to have_css(".carousel-item.active", text: "The canal")
  end
end
