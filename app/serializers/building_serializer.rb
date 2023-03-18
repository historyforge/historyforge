# frozen_string_literal: true

# == Schema Information
#
# Table name: buildings
#
#  id                    :integer          not null, primary key
#  name                  :string           not null
#  city                  :string
#  state                 :string
#  postal_code           :string
#  year_earliest         :integer
#  year_latest           :integer
#  building_type_id      :integer
#  description           :text
#  lat                   :decimal(15, 10)
#  lon                   :decimal(15, 10)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  year_earliest_circa   :boolean          default(FALSE)
#  year_latest_circa     :boolean          default(FALSE)
#  address_house_number  :string
#  address_street_prefix :string
#  address_street_name   :string
#  address_street_suffix :string
#  stories               :float
#  annotations_legacy    :text
#  lining_type_id        :integer
#  frame_type_id         :integer
#  block_number          :string
#  created_by_id         :integer
#  reviewed_by_id        :integer
#  reviewed_at           :datetime
#  investigate           :boolean          default(FALSE)
#  investigate_reason    :string
#  notes                 :text
#  locality_id           :bigint
#  building_types_mask   :integer
#  parent_id             :bigint
#  hive_year             :integer
#
# Indexes
#
#  index_buildings_on_building_type_id  (building_type_id)
#  index_buildings_on_created_by_id     (created_by_id)
#  index_buildings_on_frame_type_id     (frame_type_id)
#  index_buildings_on_lining_type_id    (lining_type_id)
#  index_buildings_on_locality_id       (locality_id)
#  index_buildings_on_parent_id         (parent_id)
#  index_buildings_on_reviewed_by_id    (reviewed_by_id)
#
class BuildingSerializer < ApplicationSerializer
  def serializable_attributes
    %i[id name year_earliest year_latest stories street_address
       building_type_ids type frame lining photo architects census_records
       latitude longitude]
  end
end
