# == Schema Information
#
# Table name: annotations
#
#  id              :bigint           not null, primary key
#  annotation_text :text
#  map_overlay_id  :bigint
#  building_id     :bigint
#
# Indexes
#
#  index_annotations_on_building_id                     (building_id)
#  index_annotations_on_building_id_and_map_overlay_id  (building_id,map_overlay_id) UNIQUE
#  index_annotations_on_map_overlay_id                  (map_overlay_id)
#

# frozen_string_literal: true

class Annotation < ApplicationRecord
  belongs_to :map_overlay, optional: false
  belongs_to :building, optional: false
  validates_presence_of :annotation_text, message: 'No annotation text.'
  validates_uniqueness_of :annotation_text, scope: [:map_overlay, :building], message: 'Duplicate annotations for Map Layer.'

  delegate :name, to: :map_overlay, prefix: true
  delegate :name, to: :building, prefix: true

  def annotation_building
    [building_name, '-', annotation_text].compact.join(' ')
  end

  def annotation_layer
    [map_overlay_name, '-', annotation_text].compact.join(' ')
  end

end
