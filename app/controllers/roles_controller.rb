# frozen_string_literal: true

class RolesController < ApplicationController
  layout 'application'
  before_action :check_administrator_role

  def index
    @user = User.find(params[:user_id])
    @all_roles = Role.current
  end

  def update
    @user = User.find(params[:user_id])
    @role = Role.find(params[:id])
    # Only add direct roles, not inherited ones
    direct_role_ids = Role.ids_from_mask(@user.roles_mask)
    @user.add_role @role unless direct_role_ids.include?(@role.id)
    redirect_to action: 'index'
  end

  def destroy
    @user = User.find(params[:user_id])
    @role = Role.find(params[:id])
    # Only remove direct roles, not inherited ones
    direct_role_ids = Role.ids_from_mask(@user.roles_mask)
    @user.remove_role @role if direct_role_ids.include?(@role.id)
    redirect_to action: 'index'
  end
end
