class MapOverlay < ApplicationRecord
  acts_as_list
  has_and_belongs_to_many :localities
  has_many :annotations
  :name
  accepts_nested_attributes_for :annotations, allow_destroy: true, reject_if: proc { |p| p['annotation_text'].blank? }

  def self.input_field_options
    order(:position).map { |item| [item.name, item.id] }
  end
end
