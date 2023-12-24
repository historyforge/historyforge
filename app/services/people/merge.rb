# frozen_string_literal: true

module People
  class Merge
    def initialize(source, target)
      @source = source
      @target = target
    end

    def perform
      @target.update_column :description, [@target.description, @source.description].compact_blank.join("\n\n")
      merge_names
      merge_census_records
      merge_photographs
      @source.reload.destroy
      @target.reload
      @target.audit_logs.create message: "Merged ##{@source.id} - #{@source.name}"
    end

    private

    def merge_names
      @source.names.each do |name|
        @target.add_name_from!(name)
      end
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
  end
end
