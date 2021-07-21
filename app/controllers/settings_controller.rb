# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :check_administrator_role

  def index
    @settings = Setting.order(:group, :name).where.not(name: 'Test mode')
  end

  def create
    settings = Setting.order(:group, :name).index_by(&:id)
    params[:settings].each do |key, param|
      settings[key.to_i].update value: param[:value]
    end

    @settings = settings.values

    render layout: false, action: :index
  end
end
