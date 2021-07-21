class Cms::PageWidget < ActiveRecord::Base

  include ArDocStore::Model

  self.table_name = 'cms_page_widgets'

  belongs_to :page, class_name: 'Cms::Page', foreign_key: 'cms_page_id'
  validates :name, :human_name, presence: true

  json_attribute :name, as: :string
  json_attribute :human_name, as: :string
  json_attribute :access_callback, as: :string
  json_attribute :css_class, as: :string
  json_attribute :css_id, as: :string
  json_attribute :css_clear, :enumeration, values: %w{none both left right}, strict: true

  json_attribute :cached_html, as: :string

  def html
    cached_html || cache_html
  end

  def render
      "<p>Override #{self.class.to_s}#render</p>"
  end

  def cache_html
    self.cached_html = render
  end

end
