class Cms::Embed < Cms::PageWidget

  json_attribute :title, as: :string
  json_attribute :embed_code, as: :string
  json_attribute :embed_url, as: :string

  before_save :cache_html

  def render
    EmbedRenderer.new(self).render
  end

  class EmbedRenderer
    include ActionView::Helpers::TagHelper
    attr_reader :embed
    def initialize(embed)
      @embed = embed
    end
    def render
      html_options = { class: 'cms-slide cms-embed ' }
      html_options[:class] << embed.css_class if embed.css_class?
      html_options[:id] = embed.css_id if embed.css_id
      html_options[:style] = "padding-top:56.2%;width:100%;position:relative;"
      if embed.css_clear.present? && embed.css_clear != 'none'
        html_options[:style] << "clear: #{embed.css_clear};"
      end

      if embed.embed_url?
        url = tranform_embed_url(embed.embed_url)
        html = embed_url_to_iframe(url)
      elsif embed.embed_code?
        html = embed.embed_code
      end

      content_tag :div, html, html_options
    end

    private

    def embed_url_to_iframe(url)
      content_tag :iframe, '', {
        src: url,
        frameborder: '0',
        allowfullscreen: true,
        style: 'position:absolute;top:0;left:0;width:100%;height:100%;'
      }
    end

    def tranform_embed_url(url)
      if url =~ /youtu\.be/
        url.sub /youtu\.be/, "www.youtube.com/embed"
      elsif url =~ /youtube\.com\/watch\?v/
        url.sub /watch\?v=/, 'embed/'
      elsif url =~ /vimeo/
        url.sub /vimeo\.com/, "player.vimeo.com/video"
      else
        url
      end

    end
  end

end
