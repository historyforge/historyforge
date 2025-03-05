# frozen_string_literal: true

module Buildings
  # Handles the merging of buildings.
  class MergesController < ApplicationController
    before_action :load_and_authorize

    def new; end

    def create
      if Buildings::Merge.run!(source: @source, target: @target)
        flash[:notice] = 'The merge operation has been performed.'
        redirect_to @target
      else
        flash[:error] = "You can't merge these buildings. They aren't close enough to be the same building."
        redirect_back fallback_location: { action: :new }
      end
    end

    private

    def load_and_authorize
      authorize! :merge, Building
      @source = Building.find(params[:merge_id])
      @target = Building.find(params[:building_id])
    end
  end
end
