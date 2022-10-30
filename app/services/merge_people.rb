# frozen_string_literal: true

class MergePeople
  def initialize(source, target)
    @source = source
    @target = target
  end

  def perform
    @target.update_column :description, [@target.description, @source.description].compact_blank.join("\n\n")
    merge_census_records
    merge_photographs
    @source.reload.destroy
    @target.reload
  end

  private

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
