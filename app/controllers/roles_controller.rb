# frozen_string_literal: true

class RolesController < ApplicationController
  before_action :check_administrator_role

  def index
    @user = User.find(params[:user_id])
    @all_roles = Role.current
  end

  def update
    @user = User.find(params[:user_id])
    @role = Role.find(params[:id])
    @user.add_role @role unless @user.has_direct_role?(@role)
    redirect_to action: 'index'
  end

  def destroy
    @user = User.find(params[:user_id])
    @role = Role.find(params[:id])
    @user.remove_role @role if @user.has_direct_role?(@role)
    redirect_to action: 'index'
  end
end
