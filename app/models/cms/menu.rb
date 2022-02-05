# == Schema Information
#
# Table name: cms_menus
#
#  id         :integer          not null, primary key
#  name       :string
#  data       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

module Cms
  class Menu < Cms::BaseModel

    include ArDocStore::Model

    self.table_name = 'cms_menus'

    json_attribute :css_id, :string
    json_attribute :css_class, :string
    json_attribute :access_callback, :string
    json_attribute :theme_callback, :string, default: :menu_list
    json_attribute :item_theme_callback, :string, default: :menu_list_item

    has_many :items, class_name: '::Cms::MenuItem'
    accepts_nested_attributes_for :items

    validates :name, presence: true

  end
end
