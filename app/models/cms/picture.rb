class Cms::Picture < Cms::PageWidget

  has_one_attached :file

  json_attribute :style, as: :string
  json_attribute :width, as: :integer
  json_attribute :height, as: :integer
  json_attribute :caption, as: :string
  json_attribute :alt_text, as: :string
  json_attribute :bootstrap_class, as: :enumeration, values: %w{thumbnail rounded circle}, strict: true
  json_attribute :alignment, as: :enumeration, values: %w{left center right parallax}, strict: true
  json_attribute :outlink, as: :string
  json_attribute :new_tab, as: :boolean, default: true
  json_attribute :nofollow, as: :boolean, default: true

  before_save :cache_html

  def self.style_options
    [
      ['Full Width Picture', 'full'],
      ['Half Width Picture', 'half'],
      ['Third Width Picture', 'third'],
      ['Quarter Width Picture', 'quarter'],
      ['Raw Image URL', 'raw'],
      ['Parallax', 'parallax']
    ]
  end

  def render
    if style.present?
      if style == 'raw'
        RawImgTagRenderer.new(self).render
      elsif style == 'parallax'
        ParallaxRenderer.new(self).render
      else
        PictureTagRenderer.new(self).render
      end
    else
      ImgTagRenderer.new(self).render
    end
  end

  def url
    file.attached? && Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
  end

  class BaseRenderer
    include ActionView::Helpers::TagHelper
    attr_reader :picture

    def initialize(picture)
      @picture = picture
    end

    def render
      html = render_image.html_safe

      if picture.outlink?
        link_options = { href: picture.outlink }
        link_options[:target] = '_blank' if picture.new_tab?
        link_options[:rel] = 'nofollow' if picture.nofollow?
        html = content_tag :a, html, link_options
      end
      if picture.caption?
        html << content_tag(:p, picture.caption)
      end

      html_options = { class: 'cms-image ' }
      html_options[:id] = picture.css_id if picture.css_id?
      html_options[:class] << picture.css_class if picture.css_class?
      if picture.css_clear.present? && picture.css_clear != 'none'
        html_options[:style] = "clear: #{picture.css_clear}"
      end

      if picture.alignment?
        html_options[:class] << " img-#{picture.alignment}"
        html = content_tag(:div, html) if picture.alignment == 'center'
      end

      content_tag :div, html, html_options
    end
  end

  class ImgTagRenderer < BaseRenderer
    def render_image
      html_options = {}
      style_attr = ''
      style_attr << "width:#{picture.width}px;" if picture.width?
      style_attr << "height:#{picture.height}px;" if picture.height?
      html_options[:style] = style_attr if style_attr.present?
      html_options[:alt] = picture.alt_text if picture.alt_text?
      html_options[:src] = picture.url
      html_options[:class] = "img-responsive"
      html_options[:class] << " img-#{picture.bootstrap_class}" if picture.bootstrap_class?
      tag :img, html_options
    end
  end

  class ParallaxRenderer < BaseRenderer
    def render
      html = ''

      if picture.caption?
        html = content_tag(:h1, picture.caption).html_safe
      end

      html_options = { class: 'cms-slide cms-image ' }
      html_options[:id] = picture.css_id if picture.css_id?
      html_options[:class] << picture.css_class if picture.css_class?
      if picture.css_clear.present? && picture.css_clear != 'none'
        html_options[:style] = "clear: #{picture.css_clear}"
      end

      style_attr = ''
      style_attr << "min-width:#{picture.width}px;" if picture.width?
      style_attr << "min-height:#{picture.height}px;" if picture.height?
      html_options[:style] = style_attr if style_attr.present?
      html_options['data-image-src'] = picture.url
      html_options['data-parallax'] = 'scroll'
      html_options['data-position'] = 'top'
      html_options['data-bleed'] = '10'

      content_tag :div, html.html_safe, html_options
    end
  end

  class PictureTagRenderer < BaseRenderer
    def render_image
      img_class = picture.bootstrap_class? ? "img-#{picture.bootstrap_class}" : nil
      return <<-EOD
      <img src="#{picture.url}" alt="#{picture.alt_text}" title="" class="img #{img_class}">
      EOD
    end
  end

  class RawImgTagRenderer < BaseRenderer
    def render
      picture.url
    end
  end
end
