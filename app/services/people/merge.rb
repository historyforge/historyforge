# frozen_string_literal: true

module People
  class Merge
    def initialize(source, target)
      @source = source
      @target = target
    end

    def perform
      @target.description = [@target.description, @source.description].compact_blank.join("\n\n")
      %i[birth_year death_year is_birth_year_estimated pob is_pob_estimated sex race].each do |attr|
        @target[attr] ||= @source[attr]
      end
      @target.save
      merge_names
      merge_census_records
      merge_photographs
      merge_localities
      @source.reload.destroy
      @target.reload
      @target.audit_logs.create message: "Merged ##{@source.id} - #{@source.first_name} #{@source.last_name}"
    end

    private

    def merge_names
      @source.names.each do |name|
        next if @target.names.any? { |target_name| name.same_name_as?(target_name) }

        @target.names.create(first_name: name.first_name, last_name: name.last_name)
      end
      @target.save
    end

    def merge_census_records
      CensusYears.each do |year|
        CensusRecord.for_year(year).where(person_id: @source.id).update_all(person_id: @target.id)
      end
    end

    def merge_photographs
      @source.photos.each do |photo|
        photo.people << @target
      end
    end

    def merge_localities
      @source.locality_ids.each do |locality_id|
        @target.locality_ids << locality_id unless @target.locality_ids.include?(locality_id)
      end
    end
  end
end
