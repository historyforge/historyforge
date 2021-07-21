module Cms
  class Page < Cms::BaseModel

    self.table_name = 'cms_pages'

    include ArDocStore::Model

    json_attribute :css_class, :string
    json_attribute :css_id, :string
    json_attribute :access_callback, :string
    json_attribute :notes, :string
    json_attribute :automatic_url_alias, :boolean, default: true

    json_attribute :template_sections, :array
    json_attribute :template, :string, default: "{{content}}"

    json_attribute :title, :string
    json_attribute :show_title, :boolean, default: true
    json_attribute :keywords, :string
    json_attribute :description, :string
    json_attribute :browser_title, :string

    json_attribute :css, :string
    json_attribute :css_compiled, :string

    has_many :widgets, class_name: '::Cms::PageWidget', dependent: :destroy, inverse_of: :page, foreign_key: :cms_page_id
    accepts_nested_attributes_for :widgets, reject_if: :all_blank, allow_destroy: true

    embeds_many :dummy_vars, class_name: '::Cms::Page::DummyVar'

    validates :title, presence: true
    validates :url_path, presence: true, uniqueness: true

    before_validation :set_url_path, if: :is_app_page?
    after_validation :add_slash_to_url_path
    before_save :set_visibility
    # before_save :compile_css
    after_update :expire #, if: :template_changed?
    after_destroy :expire

    def display_type
      if controller.present? && action.present?
        'App Page'
      else
        type.sub /Cms\:\:/, ''
      end
    end

    def formatted_url
      @formatted_url ||= url_path.present? && !url_path.starts_with?('/') ? "/#{url_path}" : url_path
    end

    def self.generate
      page = new
      # body = Cms::Text.new name: 'body', human_name: 'Body'
      # page.widgets << body
      page
    end

    def self.load(url)
      where(url_path: url).first
    end

    def render(view_template, *args)
      Cms::PageRenderer.run(self, view_template, *args)
    end

    def expire
      Cms::PageRenderer.expire(self)
    end

    # def compile_css
    #   if css?
    #     self.css_compiled = Cms::PageCssCompiler.run(self)
    #   elsif css_compiled?
    #     self.css_compiled = nil
    #   end
    # end

    attr_reader :clear_dummy_vars
    def clear_dummy_vars=(value)
      self.dummy_vars = [] if value == '1'
    end

    class DummyVar
      include ArDocStore::EmbeddableModel
      json_attribute :name, :string
      json_attribute :content, :string
    end

    def is_app_page?
      controller.present? && action.present?
    end

    def add_slash_to_url_path
      self.url_path = url_path.andand.strip
      self.url_path = "/#{url_path}" if url_path.present? && !url_path.starts_with?('/')
      self.title = title.andand.strip
      true # TODO: remove this in Rails 5.1 because throw :abort covers this now
    end

    def set_url_path
      self.url_path = "/#{controller.sub(/Controller/, '').gsub('::', '/').downcase}/#{action}"
      true
    end

    def set_visibility
      self.visible = controller.blank? && action.blank?
      true
    end

    def all_template_sections
      @all_template_sections ||= widgets.inject({}) {|hash, item|
        hash[item.name] = item
        hash
      }
    end
  end
end
