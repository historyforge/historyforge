class Annotation < ApplicationRecord
  belongs_to :map_overlay, optional: false
  belongs_to :building, optional: false
  validates_presence_of :annotation_text, :message => 'No annotation text.'
  validates_uniqueness_of :annotation_text, scope: [:map_overlay, :building], :message => 'Duplicate annotations for Map Layer.'

  delegate :name, to: :map_overlay, prefix: true
  delegate :name, to: :building, prefix: true

  def annotation_building
    [building_name, '-', annotation_text].compact.join(' ')
  end

  def annotation_layer
    [map_overlay_name, '-', annotation_text].compact.join(' ')
  end

end