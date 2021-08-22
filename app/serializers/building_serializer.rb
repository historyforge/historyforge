class BuildingSerializer
  include FastJsonapi::ObjectSerializer

  attribute :name do |object|
    object.proper_name? ? object.name : object.street_address
  end

  attributes :id, :year_earliest, :year_latest, :description, :stories,
             :street_address, :building_type_ids

  has_many :architects, serializer: ArchitectSerializer
  has_many :photos, serializer: PhotoSerializer

  attribute :type, &:building_type_name

  attribute :frame, &:frame_type_name

  attribute :lining, &:lining_type_name

  attribute :photo do |object|
    object.photos&.first&.id
  end

  attribute :latitude

  attribute :longitude

  attribute :census_records do |object, _params|
    object
      .residents
      .group_by(&:year)
      .each_with_object({}) { |data, hash|
        hash[data[0]] = data[1].map { |item| CensusRecordSerializer.new(item).as_json['data']['attributes'] }
      }
  end
end
