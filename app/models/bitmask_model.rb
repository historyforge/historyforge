# frozen_string_literal: true

# Provides basic functionality for many-many bitmasks. Just extend the class and define DATA constant as array
# of names. See BuildingType for example.
class BitmaskModel
  attr_accessor :id, :name

  class_attribute :data
  class_attribute :descriptions

  def self.for_select
    all.map { |item| [item.name, item.id] }
  end

  def self.all
    data.map.with_index { |item, i| new id: i + 1, name: item }.sort_by(&:name)
  end

  def self.find(id)
    return unless id

    id = id.to_i if id.respond_to?(:to_i)
    all.detect { |item| item.id == id }
  end

  def self.find_by(name:)
    name = name.titleize
    all.detect { |item| item.name == name }
  end

  def self.from_mask(mask)
    return [] if mask.blank?

    all.select { |item| mask.anybits?((2**item.id)) }
  end

  def self.ids_from_mask(mask)
    from_mask(mask).map(&:id)
  end

  def self.mask_from_ids(ids)
    (ids.map(&:to_i) & all.map(&:id)).sum { |id| 2**id }
  end

  def self.mask_for(ids)
    ids = [ids] unless ids.is_a?(Array)
    ids.inject(0) { |bitmask, id| bitmask | (2**id.to_i) }
  end

  def initialize(id:, name:)
    @name = name
    @id = id
  end

  def description
    self.class.descriptions && self.class.descriptions[id - 1]
  end
end
