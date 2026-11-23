# frozen_string_literal: true

class ForgeController < ApplicationController
  include BotDetection

  def photographs
    building = Building.find(params[:id])
    authorize! :read, building
    photos = building.photos.accessible_by(current_ability).joins(:file_attachment)
                     .in_chronological_order.order(:id)
    render json: {
      id: building.id, address: building.primary_street_address,
      url: building_path(building), can_edit: can?(:update, building),
      description: building.description&.to_plain_text,
      nearby: (building.lat? ? building.nearbys(0.1).accessible_by(current_ability).limit(8).includes(:addresses) : []).map { |neighbor|
        { id: neighbor.id, address: neighbor.primary_street_address }
      },
      photos: photos.map { |photo|
        { id: photo.id, caption: photo.caption, date: photo.date_text,
          description: photo.description, creator: photo.creator,
          url: photograph_path(photo), can_edit: can?(:update, photo),
          thumbnail: url_for(photo.file.variant(resize_to_limit: [320, 240])),
          image: url_for(photo.file.variant(resize_to_limit: [1600, 1200])) }
      }
    }
  end

  def index
    @layers = MapOverlay.order(:position).where(active: true)
    @layers = @layers.joins(:localities).where(localities: { id: Current.locality_id }) if Current.locality_id
  end
end
