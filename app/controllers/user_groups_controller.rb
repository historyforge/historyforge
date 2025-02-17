# frozen_string_literal: true

class UserGroupsController < ApplicationController
  before_action :check_administrator_role

  def index
    @user_groups = UserGroup.all
  end

  def new
    @user_group = UserGroup.new
  end

  def create
    @user_group = UserGroup.new resource_params
    if @user_group.save
      flash[:notice] = 'Added the new user group.'
      redirect_to action: :index
    else
      flash[:error] = "Sorry couldn't do it."
      render action: :new
    end
  end

  def edit
    @user_group = UserGroup.find params[:id]
  end

  def update
    @user_group = UserGroup.find params[:id]
    if @user_group.update resource_params
      flash[:notice] = 'Updated the user group.'
      redirect_to action: :index
    else
      flash[:error] = "Sorry couldn't do it."
      render action: :edit
    end
  end

  def destroy
    @user_group = UserGroup.find params[:id]
    if @user_group.destroy
      flash[:notice] = 'Deleted the user group.'
      redirect_to action: :index
    else
      flash[:error] = "Sorry couldn't do it."
      redirect_back fallback_location: { action: :index }
    end
  end

  private

  def resource_params
    params.require(:user_group).permit(:name)
  end
end
