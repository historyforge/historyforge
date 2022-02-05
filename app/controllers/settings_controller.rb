# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :check_administrator_role

  def index
    if params[:group_id]
      @group = SettingsGroup.find params[:group_id]
      @settings = @group.settings.order(:name).where.not(name: 'Test mode')
    else
      @groups = SettingsGroup.all
    end
  end

  def create
    @group = SettingsGroup.find params[:group_id]
    settings = @group.settings.order(:name).index_by(&:id)
    params[:settings].each do |key, param|
      settings[key.to_i].update value: param[:value]
    end
    Setting.expire_cache
    redirect_to settings_path(group_id: @group.id)
  end
end
