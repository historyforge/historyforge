module Buildings
  class MergesController < ApplicationController
    before_action :load_and_authorize

    def new
    end

    def create
      if @check.okay?
        MergeBuilding.new(@source, @target).perform
        flash[:notice] = "The merge operation has been performed."
        redirect_to @target
      else
        flash[:errors] = "You can't merge these buildings."
        redirect_back fallback_location: { action: :new }
      end
    end

    private

    def load_and_authorize
      authorize! :merge, Building
      @target = Building.find(params[:building_id]).with_residents
      @source = Building.find(params[:merge_id]).with_residents
      @check = BuildingMergeEligibilityCheck.new(@source, @target)
      @check.perform
    end
  end
end