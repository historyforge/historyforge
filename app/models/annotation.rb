class Annotation < ApplicationRecord
  belongs_to :building
  belongs_to :map_overlay
  validates_presence_of :annotation_text

  def self.from(item)
    if item.kind_of?(Building)
      item.annotations.find_or_create_by(
        building:  item,
        map_layer: item.read_attribute(:map_overlay),
        annotation_text: item.read_attribute(:annotation_text),
        is_primary:   true
      )
    end
  end
end