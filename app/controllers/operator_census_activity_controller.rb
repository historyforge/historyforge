# frozen_string_literal: true

class OperatorCensusActivityController < ApplicationController
  def show
    authorize! :search_by_creator, CensusRecord
    return if params[:creator_id].blank?

    @creator = User.find_by(id: Integer(params[:creator_id].to_s, 10, exception: false))
    return head :not_found unless @creator

    @counts = {}
    CensusYears.each_visible_to_user(current_user) do |year|
      records = CensusYears.class_for(year).where(created_by_id: @creator.id)
      records = records.where(locality_id: Current.locality_id) if Current.locality_id
      count = records.count
      @counts[year] = count if count.positive?
    end
  end
end
