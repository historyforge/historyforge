# frozen_string_literal: true

class NarrativesController < MediaController
  self.model_class = Narrative
  self.model_association = :narratives

  def show
    @asset = scoped_model.find params[:id]
    authorize! :read, @asset
  end

  def new
    @asset = scoped_model.new
    authorize! :create, @asset

    if @building
      @asset.buildings << @building
    elsif @person
      @asset.people << @person
    end
  end

  private

  def resource_params
    params
      .require(:narrative)
      .permit :source, :story, :weight,
              { building_ids: [], person_ids: [] },
              :date_text, :date_start, :date_end, :date_type,
              :notes,
              :date_year, :date_month, :date_day,
              :date_year_end,
              :date_month_end,
              :date_day_end
  end
end
