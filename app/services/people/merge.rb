# frozen_string_literal: true

module People
  class Merge < ApplicationInteraction
    MERGEABLE_ATTRIBUTES = %i[
      birth_year death_year is_birth_year_estimated
      pob is_pob_estimated sex race
    ].freeze

    object :source, class: Person
    object :target, class: Person

    def execute
      ActiveRecord::Base.transaction do
        merge_descriptions
        merge_basic_attributes
        merge_associations
        create_audit_log
      end
      target.reload
    end

    private

    def merge_descriptions
      target.description = [target.description, source.description]
        .compact_blank
        .join("\n\n")
      target.save
    end

    def merge_basic_attributes
      MERGEABLE_ATTRIBUTES.each do |attr|
        target[attr] ||= source[attr]
      end
      target.save
    end

    def merge_associations
      merge_names
      merge_census_records
      merge_photographs
      merge_localities
      source.reload.destroy
    end

    def merge_names
      source.names.each do |name|
        next if target.names.any? { |target_name| name.same_name_as?(target_name) }
        target.names.create(name.attributes.except("id", "person_id", "created_at", "updated_at"))
      end
    end

    def merge_census_records
      CensusYears.each do |year|
        CensusRecord.for_year(year)
          .where(person_id: source.id)
          .update_all(person_id: target.id)
      end
    end

    def merge_photographs
      source.photos.each { |photo| photo.people << target }
    end

    def merge_localities
      new_locality_ids = source.locality_ids - target.locality_ids
      target.locality_ids.concat(new_locality_ids)
    end

    def create_audit_log
      target.audit_logs.create(
        message: "Merged ##{source.id} - #{source.first_name} #{source.last_name}",
      )
    end
  end
end
