# == Schema Information
#
# Table name: map_overlays
#
#  id            :bigint           not null, primary key
#  name          :string
#  year_depicted :integer
#  url           :string
#  active        :boolean
#  position      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  locality_id   :bigint
#  layers_param  :string
#
# Indexes
#
#  index_map_overlays_on_locality_id  (locality_id)
#

# frozen_string_literal: true

class MapOverlay < ApplicationRecord
  acts_as_list
  has_and_belongs_to_many :localities
  has_many :annotations, dependent: :restrict_with_error
  accepts_nested_attributes_for :annotations, reject_if: proc { |p| p['annotation_text'].blank? }
  default_scope -> { order(:year_depicted) }
  def can_delete?
    annotations.count == 0
  end

  def self.input_field_options
    order(:position).map { |item| [item.name, item.id] }
  end
end
