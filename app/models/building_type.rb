# frozen_string_literal: true

# Data dictionary for building types. Since a building can have many building types, it is a structured
# as a bitmask.
class BuildingType
  # You can add to this list but if you reorder or remove items, you will screw up the data
  DATA = %w[Public Marker Residence Religious Commercial].freeze

  attr_accessor :id, :name

  def self.for_select
    all.map { |item| [item.name, item.id] }
  end

  def self.all
    DATA.map.with_index { |item, i| new id: i + 1, name: item }.sort_by(&:name)
  end

  def self.find(id)
    return unless id

    row = DATA[id + 1]
    row && new(id: id + 1, name: row)
  end

  def self.from_mask(mask)
    return [] if mask.blank?

    all.select { |item| (mask & 2**item.id).positive? }
  end

  def self.ids_from_mask(mask)
    from_mask(mask).map(&:id)
  end

  def self.mask_from_ids(ids)
    (ids.map(&:to_i) & all.map(&:id)).map { |id| 2**id }.sum
  end

  def self.mask_for(ids)
    ids.inject(0) do |bitmask, id|
      value = case id.class
              when String
                id.to_i
              when TrueClass
                1
              else
                0
              end
      bitmask | 2**value
    end
  end

  def initialize(id:, name:)
    @name = name
    @id = id
  end
end
