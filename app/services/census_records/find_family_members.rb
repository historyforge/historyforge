# frozen_string_literal: true

module CensusRecords
  # Finds the other family members of this census record. Wants the same locality_id, building_id or dwelling_number,
  # same enumeration district, but allows census page before or after.
  class FindFamilyMembers < ApplicationInteraction
    object :record, class: 'CensusRecord'

    delegate :locality_id, :enum_dist, :family_id, :page_number, :building_id, :dwelling_number, :id, to: :record

    def execute
      record.class.where.not(id:).in_census_order.ransack(options).result
    end

    def options
      base_options.merge!(building_options)
    end

    def base_options
      {
        locality_id_eq: locality_id,
        enum_dist_eq: enum_dist,
        family_id_eq: family_id,
        page_number_gteq: page_number - 1,
        page_number_lteq: page_number + 1
      }
    end

    def building_options
      return { build_id_eq: building_id } if building_id
      return { dwelling_number_eq: dwelling_number } if dwelling_number

      {}
    end
  end
end
