# frozen_string_literal: true

module People
  class Merge
    def self.call(source:, target:)
      new(source:, target:).call
    end

    def initialize(source:, target:)
      @source = source
      @target = target
    end

    MERGEABLE_ATTRIBUTES = %i[
      birth_year is_birth_year_estimated death_year
      is_death_year_estimated pob is_pob_estimated sex race
    ].freeze

    def call
      ActiveRecord::Base.transaction do
        merge_descriptions
        merge_basic_attributes
        merge_associations
        create_audit_log
      end
      source.reload.destroy
      target.reload
    end

    private

    attr_reader :source, :target

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
      merge_narratives
      merge_audios
      merge_videos
      merge_localities
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
          .find_each do |record|
            record.update!(person_id: target.id)
          end
      end
    end

    def merge_photographs
      source.photos.each do |photo|
        photo.people << target unless photo.people.include?(target)
      end
    end

    def merge_narratives
      source.narratives.each do |narrative|
        narrative.people << target unless narrative.people.include?(target)
      end
    end

    def merge_audios
      source.audios.each do |audio|
        audio.people << target unless audio.people.include?(target)
      end
    end

    def merge_videos
      source.videos.each do |video|
        video.people << target unless video.people.include?(target)
      end
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
