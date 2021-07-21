class MergeEligibilityCheck
  def initialize(source, target)
    @source, @target = source, target
  end

  def perform
    @clashes = []
    @clashes << 1900 if @source.census_1900_record && @target.census_1900_record
    @clashes << 1910 if @source.census_1910_record && @target.census_1910_record
    @clashes << 1920 if @source.census_1920_record && @target.census_1920_record
    @clashes << 1930 if @source.census_1930_record && @target.census_1930_record
  end

  def okay?
    @clashes.blank?
  end

  def years
    @clashes
  end
end