class BuildingSerializer
  include FastJsonapi::ObjectSerializer

  attribute :name do |object|
    object.has_proper_name? ? object.name : object.street_address
  end

  attributes :id, :year_earliest, :year_latest, :description, :stories,
             :street_address, :building_type_ids

  has_many :architects, serializer: ArchitectSerializer
  has_many :photos, serializer: PhotoSerializer

  attribute :type do |object|
    object.building_type_name
  end

  attribute :frame do |object|
    object.frame_type_name
  end

  attribute :lining do |object|
    object.lining_type_name
  end

  attribute :photo do |object|
    object.photos.andand.first.andand.id
  end

  attribute :latitude do |object|
    object.lat
  end

  attribute :longitude do |object|
    object.lon
  end

  attribute :census_records do |object, params|
    if object.residents
      object
        .residents
        .group_by(&:year)
        .reduce({}) { |hash, data|
          hash[data[0]] = data[1].map { |item| CensusRecordSerializer.new(item).as_json['data']['attributes'] }
          hash
        }

    else
      {
        1900 => object.census_1900_records.andand.map { |item| CensusRecordSerializer.new(item).as_json['data']['attributes'] },
        1910 => object.census_1910_records.andand.map { |item| CensusRecordSerializer.new(item).as_json['data']['attributes'] },
        1920 => object.census_1920_records.andand.map { |item| CensusRecordSerializer.new(item).as_json['data']['attributes'] },
        1930 => object.census_1930_records.andand.map { |item| CensusRecordSerializer.new(item).as_json['data']['attributes'] },
        1940 => object.census_1940_records.andand.map { |item| CensusRecordSerializer.new(item).as_json['data']['attributes'] }
      }
    end
  end
end
