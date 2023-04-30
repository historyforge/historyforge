# frozen_string_literal: true

module CensusRecords
  # Finds the other family members of this census record. Wants the same locality_id, building_id or dwelling_number,
  # same enumeration district, but allows census page before or after.
  class FindFamilyMembers < ApplicationInteraction
    object :record, class: 'CensusRecord'

    delegate :locality_id, :enum_dist, :family_id, :page_number, :building_id, :dwelling_number, :id, to: :record

    def execute
      record.class.where.not(id:).in_census_order.where(options)
    end

    def options
      {
        locality_id:,
        enum_dist:,
        family_id:,
        **(building_id ? { building_id: } : {}),
        **(dwelling_number ? { dwelling_number: } : {})
      }
    end
  end
end
