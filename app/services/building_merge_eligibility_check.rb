# frozen_string_literal: true

class BuildingMergeEligibilityCheck
  def initialize(source, target)
    @source, @target = source, target
  end

  def perform
    # how far apart are they?
    @clashes = []
  end

  def okay?
    @clashes.blank?
  end

  def years
    @clashes
  end
end
