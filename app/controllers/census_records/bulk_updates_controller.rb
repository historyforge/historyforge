# frozen_string_literal: true

module CensusRecords
  class BulkUpdatesController < ApplicationController
    def index
      authorize! :bulk_update, BulkUpdate
      @bulk_updates = BulkUpdate.where(year: year).page(params[:page] || 1).order('updated_at desc')
    end

    def show
      authorize! :bulk_update, BulkUpdate
      @bulk_update = BulkUpdate.find params[:id]
    end

    def new
      authorize! :bulk_update, BulkUpdate
      @bulk_update = BulkUpdate.new user: current_user, year: year
    end

    def edit
      authorize! :bulk_update, BulkUpdate
      @bulk_update = BulkUpdate.find params[:id]
    end

    def create
      authorize! :bulk_update, BulkUpdate
      @bulk_update = BulkUpdate.new user: current_user, year: year
      @bulk_update.attributes = params.require(:bulk_update).permit(:field)
      if @bulk_update.save
        redirect_to "/census/#{year}/bulk/#{@bulk_update.id}/edit"
      else
        render action: :new
      end
    end

    def update
      authorize! :bulk_update, BulkUpdate
      @bulk_update = BulkUpdate.find params[:id]
      @bulk_update.attributes = params.require(:bulk_update).permit(:field, :value_from, :value_to, :confirm)
      if @bulk_update.save
        if @bulk_update.confirmed?
          @bulk_update.perform
          count = @bulk_update.records.count
          flash[:notice] = "Bulk update completed! #{count} record(s) were changed."
          redirect_to "/census/#{year}/bulk/#{@bulk_update.id}"
        else
          render action: :edit
        end
      else
        flash[:errors] = 'Bulk update failed. Did you fill in the form?'
        render action: :edit
      end
    end


    def destroy
      authorize! :bulk_update, BulkUpdate
      @bulk_update = BulkUpdate.find params[:id]
      @bulk_update.destroy
      redirect_to "/census/#{year}/bulk"
    end

    def year
      @year ||= request.path.split('/')[2].to_i
    end

    def resource_class
      @resource_class ||= "Census#{year}Record".safe_constantize
    end

    helper_method :year, :resource_class
  end
end
