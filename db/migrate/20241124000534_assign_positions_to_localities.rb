# frozen_string_literal: true

class AssignPositionsToLocalities < ActiveRecord::Migration[7.2]
  def change
    position = 1
    Locality.find_each do |locality|
      locality.update(position:)
      position += 1
    end
  end
end
