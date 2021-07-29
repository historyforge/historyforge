class BuildingListingSerializer
  include FastJsonapi::ObjectSerializer

  cache_options enabled: true

  attributes :id, :year_earliest, :year_latest,
             :street_address, :building_type_ids,
             :latitude, :longitude, :addresses

  attribute :addresses do |object|
    object.addresses.map { |address| address.address }
  end

  attribute :name do |object|
    object.proper_name? ? object.name : object.street_address
  end
end
