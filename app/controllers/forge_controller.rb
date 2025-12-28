# frozen_string_literal: true

class ForgeController < ApplicationController
  include BotDetection

  def index
    @layers = MapOverlay.order(:position).where(active: true)
    @layers = @layers.joins(:localities).where(localities: { id: Current.locality_id }) if Current.locality_id
  end
end
