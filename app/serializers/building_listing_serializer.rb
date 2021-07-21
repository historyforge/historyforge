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
    object.has_proper_name? ? object.name : object.street_address
  end

  # has_many :architects, serializer: ArchitectSerializer

  # attribute :residents do |object|
  #   object.residents.present? && object
  #       .residents
  #       .map { |item| CensusRecordSerializer.new(item).as_json }
  #       .group_by { |item| item['data']['attributes']['year'] }
  # end
end
