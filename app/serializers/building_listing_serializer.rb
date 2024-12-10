# frozen_string_literal: true

class BuildingListingSerializer < ApplicationSerializer
  def serializable_attributes
    %i[id name year_earliest year_latest street_address building_type_ids latitude longitude]
  end
end
