# frozen_string_literal: true

module CensusRecords
  # Finds the other family members of this census record. Wants the same locality_id, building_id or dwelling_number,
  # same enumeration district, but allows census page before or after.
  class FindFamilyMembers < ApplicationInteraction
    object :record, class: 'CensusRecord'

    delegate :locality_id, :family_id, :page_number, :building_id, :dwelling_number, :id, to: :record

    def enum_dist
      record.enum_dist_defined? ? record.enum_dist : nil
    end

    def execute
      record.class.where(options).where.not(id:).in_census_order
    end

    def options
      {
        locality_id:,
        family_id:,
        **(building_id ? { building_id: } : {}),
        **(dwelling_number ? { dwelling_number: } : {}),
        **(record.enum_dist_defined? ? { enum_dist: } : {})
      }
    end
  end
end
