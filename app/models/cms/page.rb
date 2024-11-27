# == Schema Information
#
# Table name: cms_pages
#
#  id         :bigint           not null, primary key
#  type       :string           default("Cms::Page")
#  url_path   :string
#  controller :string
#  action     :string
#  published  :boolean          default(TRUE)
#  visible    :boolean          default(FALSE)
#  data       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_cms_pages_on_controller_and_action  (controller,action)
#  index_cms_pages_on_url_path               (url_path)
#

# frozen_string_literal: true

module Cms
  class Page < ApplicationRecord

    self.table_name = 'cms_pages'

    include ArDocStore::Model

    # @!attribute css_class
    #   @return [String, nil]
    json_attribute :css_class, :string
    # @!attribute css_id
    #   @return [String, nil]
    json_attribute :css_id, :string
    # @!attribute access_callback
    #   @return [String, nil]
    json_attribute :access_callback, :string
    # @!attribute notes
    #   @return [String, nil]
    json_attribute :notes, :string
    # @!attribute automatic_url_alias
    #   @return [Boolean]
    json_attribute :automatic_url_alias, :boolean, default: true

    # @!attribute template_sections
    #   @return [Array<String>]
    json_attribute :template_sections, :array
    # @!attribute template
    #   @return [String]
    json_attribute :template, :string, default: '{{content}}'

    # @!attribute title
    #   @return [String, nil]
    json_attribute :title, :string
    # @!attribute show_title
    #   @return [Boolean]
    json_attribute :show_title, :boolean, default: true
    # @!attribute keywords
    #   @return [String, nil]
    json_attribute :keywords, :string
    # @!attribute description
    #   @return [String, nil]
    json_attribute :description, :string
    # @!attribute browser_title
    #   @return [String, nil]
    json_attribute :browser_title, :string

    # @!attribute css
    #   @return [String, nil]
    json_attribute :css, :string
    # @!attribute css_compiled
    #   @return [String, nil]
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
      self.url_path = url_path&.strip
      self.url_path = "/#{url_path}" if url_path.present? && !url_path.starts_with?('/')
      self.title = title&.strip
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
