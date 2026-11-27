# frozen_string_literal: true

class OperatorCensusActivityController < ApplicationController
  def show
    authorize! :search_by_creator, CensusRecord
    activity = OperatorCensusActivity.new(years: CensusYears.visible_to_user(current_user), locality_id: Current.locality_id)
    @recent_operators = activity.recent_operators
    return if params[:creator_id].blank?

    @creator = User.find_by(id: Integer(params[:creator_id].to_s, 10, exception: false))
    return head :not_found unless @creator

    @counts = activity.counts_for(@creator)
  end
end
