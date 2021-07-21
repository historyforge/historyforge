class Cms::Audio < Cms::PageWidget

  has_one_attached :file
  # delegate :url, :current_path, :content_type, :filename, :to => :file

  json_attribute :title, as: :string
  json_attribute :description, as: :string

  before_save :cache_html

  def render
    AudioRenderer.new(self).render
  end

  class AudioRenderer
    include ActionView::Helpers::TagHelper
    attr_reader :audio
    def initialize(audio)
      @audio = audio
    end
    def render

      html = content_tag :source, '', { src: audio.url }
      html = content_tag :audio, html, { controls: 'controls' }

      # title
      html << content_tag(:p, audio.title, class: 'title') if audio.title?

      # description
      html << content_tag(:p, audio.description, class: 'caption') if audio.description?

      # put them together
      html_options = { class: 'cms-slide cms-audio ' }
      html_options[:class] << audio.css_class if audio.css_class?
      html_options[:id] = audio.css_id if audio.css_id?
      if audio.css_clear.present? && audio.css_clear != 'none'
        html_options[:style] << "clear: #{audio.css_clear};"
      end

      content_tag :div, html, html_options
    end
  end

end
