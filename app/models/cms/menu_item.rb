# == Schema Information
#
# Table name: cms_menu_items
#
#  id               :integer          not null, primary key
#  menu_id          :integer
#  ancestry         :string
#  title            :string
#  url              :string
#  is_external      :boolean
#  show_as_expanded :boolean
#  enabled          :boolean
#  position         :integer
#  data             :json
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_cms_menu_items_on_ancestry  (ancestry)
#  index_cms_menu_items_on_menu_id   (menu_id)
#

# frozen_string_literal: true

module Cms
  class MenuItem < Cms::BaseModel

    self.table_name = 'cms_menu_items'

    include ArDocStore::Model

    json_attribute :css_id, :string
    json_attribute :css_class, :string
    json_attribute :access_callback, :string
    json_attribute :active_callback, :string, default: :current_page?
    json_attribute :theme_callback, :string

    belongs_to :menu, foreign_key: :menu_id
    validates :title, :url, presence: true

    acts_as_list scope: :menu_id
    has_ancestry

    default_scope -> { order('position') }
    scope :root, -> { where(ancestry: nil) }

    def formatted_url
      @formatted_url || begin
        my_url = if is_external?
          if url !~ /http/
            "http://#{url}"
          else
            url
          end
        elsif url.present? && !url.starts_with?('/')
          "/#{url}"
        else
          url
        end
        @formatted_url = my_url
        @formatted_url
      end
    end

    def to_url
      formatted_url
    end

    def is_external?
      url.starts_with?('http')
    end

  end
end
