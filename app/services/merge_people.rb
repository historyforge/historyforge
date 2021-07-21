class MergePeople
  def initialize(source, target)
    @source, @target = source, target
  end

  def perform
    merge_census_records
    merge_photographs
  end

  private

  def merge_census_records
    @source.census_records.each do |record|
      record.person = @target
      record.save
    end
  end

  def merge_photographs
    @source.photographs.each do |photo|
      photo.people << @target
    end
  end
end