# frozen_string_literal: true

class BuildingSerializer < ApplicationSerializer
  def serializable_attributes
    %i[id name year_earliest year_latest stories street_address
       building_type_ids type frame lining photo architects census_records
       latitude longitude]
  end
end
