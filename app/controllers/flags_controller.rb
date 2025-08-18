# frozen_string_literal: true

class FlagsController < ApplicationController
  include RestoreSearch

  def index
    @search = Flag.unresolved.order("created_at asc").ransack(params[:q])
    @flags = @search.result
                    .preload(:flaggable, :flagged_by)
                    .includes(:flaggable)
                    .page(params[:page] || 1)
                    .per(50)
    @flags.each { |flag| flag.destroy unless flag.flaggable }
  end

  def new
    authorize! :create, Flag
    @flag = Flag.new
    @flag.flaggable = find_flaggable
    render layout: false
  end

  def create
    @flag = Flag.new params.require(:flag).permit(:reason, :message, :flaggable_type, :flaggable_id)
    @flag.flagged_by = current_user
    authorize! :create, @flag
    if @flag.save
      flash[:notice] = "The record has been flagged. An editor will be on it as soon as possible."
      redirect_back fallback_location: root_path
    else
      flash[:error] = "Something kept us from being able to flag the content. Sorry!"
    end
  end

  def show
    @flag = Flag.find params[:id]
    authorize! :update, @flag
  end

  def update
    @flag = Flag.find params[:id]
    authorize! :update, @flag
    @flag.editing_user = current_user
    @flag.attributes = params.require(:flag).permit :reason, :message, :comment, :mark_resolved
    if @flag.save
      if @flag.resolved?
        flash[:notice] = "The issue has been resolved!"
      else
        flash[:notice] = "Saved your updates. However, the issue has NOT been resolved."
      end
      redirect_back fallback_location: url_for(action: :show)
    else
      flash[:error] = "Something prevented us from saving your changes!"
      render action: :show
    end
  end

  def destroy
    @flag = Flag.find params[:id]
    authorize! :destroy, @flag
    if @flag.destroy
      flash[:notice] = "The flag has been deleted."
      redirect_back fallback_location: root_path
    else
      flash[:error] = "Something kept us from being delete the flag. Sorry!"
      redirect_to action: :show
    end
  end

  private

  def flaggable
    @flaggable ||= find_flaggable
  end

  def build_flaggable
    flaggable_class = Flag.safe_flaggable_class(params[:flaggable_type])
    @flaggable = flaggable_class&.new
  end

  def find_flaggable
    flaggable_class = Flag.safe_flaggable_class(params[:flaggable_type])
    return nil unless flaggable_class

    flaggable_class.find(params[:flaggable_id])
  end
end
