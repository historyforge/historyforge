# frozen_string_literal: true

module People
  class MergesController < ApplicationController
    before_action :load_and_authorize

    def new; end

    def create
      authorize! :merge, Person
      @target = Person.find params[:person_id]
      @source = Person.find params[:merge_id]
      People::Merge.run!(source: @source, target: @target)
      flash[:notice] = "The merge operation has been performed."
      redirect_to @target
    end

    private

    def load_and_authorize
      authorize! :merge, Person
      @target = Person.find params[:person_id]
      @source = Person.find params[:merge_id]
      @check = People::MergeEligibilityCheck.new(@source, @target)
      @check.perform
    end
  end
end
