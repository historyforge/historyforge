# frozen_string_literal: true

class ConstructionMaterial #< ApplicationRecord
  # validates :name, :color, presence: true

  # ConstructionMaterial.find_or_create_by(name: 'wood', color: 'yellow')
  # ConstructionMaterial.find_or_create_by(name: 'brick', color: 'red')
  # ConstructionMaterial.find_or_create_by(name: 'stone', color: 'blue')
  # ConstructionMaterial.find_or_create_by(name: 'iron', color: 'gray')
  # ConstructionMaterial.find_or_create_by(name: 'adobe', color: 'green')

  DATA = [
    %w[Wood Yellow],
    %w[Brick Red],
    %w[Stone Blue],
    %w[Iron Gray],
    %w[Adobe Green]
  ].freeze

  attr_accessor :id, :name, :color

  def self.for_select
    all.map { |item| [item.name, item.id] }
  end

  def self.all
    DATA.map.with_index { |item, i| new id: i + 1, name: item[0], color: item[1] }.sort_by(&:name)
  end

  def self.find(id)
    return unless id

    row = DATA[id - 1]
    row && new(id: id - 1, name: row[0], color: row[1])
  end

  def initialize(id:, name:, color:)
    @name = name
    @color = color
    @id = id
  end
end
