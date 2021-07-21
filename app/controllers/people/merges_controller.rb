module People
  class MergesController < ApplicationController
    before_action :load_and_authorize
    def new
    end

    def create
      authorize! :merge, Person
      @target = Person.find params[:person_id]
      @source = Person.find params[:merge_id]
      @check = MergeEligibilityCheck.new(@source, @target)
      @check.perform
      if @check.okay?
        MergePeople.new(@source, @target).perform
        flash[:notice] = "The merge operation has been performed."
        redirect_to @target
      else
        flash[:errors] = "You can't merge these people."
        redirect_back fallback_location: { action: :new }
      end
    end

    private

    def load_and_authorize
      authorize! :merge, Person
      @target = Person.find params[:person_id]
      @source = Person.find params[:merge_id]
      @check = MergeEligibilityCheck.new(@source, @target)
      @check.perform
    end

  end
end