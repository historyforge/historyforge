# frozen_string_literal: true

# Rails model for buildings. Census records are attached to buildings. They also have photos and some
# metadata originally designed and provided by Historic Ithaca.
class Building < ApplicationRecord
  include AutoStripAttributes
  include Moderation
  include DefineEnumeration
  include Flaggable
  include Versioning

  has_rich_text :description

  define_enumeration :address_street_prefix, %w[N S E W]
  define_enumeration :address_street_suffix, %w[St Rd Ave Blvd Pl Terr Jct Pt Tpke Ct Pk Tr Dr Hill Cir Sq Ln Fwy Hwy Way].sort

  belongs_to :locality, optional: true

  has_many :addresses, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: proc { |p| p['name'].blank? }

  has_and_belongs_to_many :architects

  has_many :annotations, dependent: :destroy
  accepts_nested_attributes_for :annotations, allow_destroy: true, reject_if: proc { |p| p['annotation_text'].blank? }

  CensusYears.each do |year|
    has_many :"census_#{year}_records", dependent: :nullify, class_name: "Census#{year}Record"
  end
  has_and_belongs_to_many :photos, class_name: 'Photograph', dependent: :nullify
  before_validation :check_locality

  validates :name, presence: true, length: { maximum: 255 }
  validates :year_earliest, :year_latest, numericality: { minimum: 1500, maximum: 2100, allow_nil: true }
  validate :validate_primary_address

  delegate :name, to: :frame_type, prefix: true, allow_nil: true
  delegate :name, to: :lining_type, prefix: true, allow_nil: true

  scope :as_of_year, lambda { |year|
    where('(year_earliest is null and year_latest is null) or (year_earliest<=:year and (year_latest is null or year_latest>=:year)) or (year_earliest is null and year_latest>=:year)', year: year)
  }

  scope :as_of_year_eq, lambda { |year|
    where('(year_earliest<=:year and (year_latest is null or year_latest>=:year)) or (year_earliest is null and year_latest>=:year)', year: year)
  }

  scope :without_residents, lambda {
    joins('LEFT OUTER JOIN census_1900_records ON census_1900_records.building_id=buildings.id')
      .joins('LEFT OUTER JOIN census_1910_records ON census_1910_records.building_id=buildings.id')
      .joins('LEFT OUTER JOIN census_1920_records ON census_1920_records.building_id=buildings.id')
      .joins('LEFT OUTER JOIN census_1930_records ON census_1930_records.building_id=buildings.id')
      .joins('LEFT OUTER JOIN census_1940_records ON census_1940_records.building_id=buildings.id')
      .where('census_1900_records.id IS NULL AND census_1910_records.id IS NULL AND census_1920_records.id IS NULL AND census_1930_records.id IS NULL AND census_1940_records.id IS NULL')
      .where(building_types: { name: 'residence' }) }

  scope :order_by, lambda { |col, dir|
    order(Arel.sql(sanitize_sql_for_order("#{col} #{dir}")))
  }

  scope :order_by_street_address, lambda { |dir|
    all
      .joins('LEFT OUTER JOIN addresses pa ON pa.building_id=buildings.id AND pa.is_primary=TRUE')
      .group('buildings.id, pa.id')
      .order('pa.name' => dir)
      .order('pa.prefix' => dir)
      .order('pa.suffix' => dir)
      .order(Arel.sql("substring(pa.house_number, '^[0-9]+')::int") => dir)
  }

  scope :by_street_address, -> { order_by_street_address('asc') }

  scope :with_multiple_addresses, -> {
    all
      .joins(:addresses)
      .group('buildings.id, addresses.name')
      .having('COUNT(addresses.name) > 1')
  }

  scope :building_types_id_in, lambda { |*ids|
    if ids.empty?
      where('building_types_mask > 0')
    else
      where 'building_types_mask & ? > 0', BuildingType.mask_for(ids)
    end
  }

  scope :building_types_id_not_in, lambda { |*ids|
    if ids.empty?
      where('building_types_mask = 0')
    else
      where.not 'building_types_mask & ? > 0', BuildingType.mask_for(ids)
    end
  }

  scope :building_types_id_null, -> { where(building_types_mask: nil) }
  scope :building_types_id_not_null, -> { where.not(building_types_mask: nil) }

  def self.ransackable_scopes(_auth_object=nil)
    %i[as_of_year without_residents as_of_year_eq
     building_types_id_in building_types_id_not_in building_types_id_null building_types_id_not_null]
  end

  Geocoder.configure(
    timeout: 2,
    use_https: true,
    lookup: :google,
    api_key: AppConfig[:geocoding_key]
  )

  geocoded_by :full_street_address, latitude: :lat, longitude: :lon
  after_validation :do_the_geocode, if: :new_record?

  ransacker :street_address, formatter: proc { |v| v.mb_chars.downcase.to_s } do
    addresses = Address.arel_table
    Arel::Nodes::NamedFunction.new('LOWER',
                                   [Arel::Nodes::NamedFunction.new('concat_ws',
                                                                   [Arel::Nodes::Quoted.new(' '),
                                                                    addresses[:house_number],
                                                                    addresses[:prefix],
                                                                    addresses[:name],
                                                                    addresses[:suffix]
                                                                   ])])
  end

  auto_strip_attributes :name, :stories

  alias_attribute :latitude, :lat
  alias_attribute :longitude, :lon
  alias_attribute :longitude, :lon

  def proper_name?
    name && (address_house_number.blank? || !name.include?(address_house_number))
  end

  def do_the_geocode
    return if Rails.env.test?

    geocode
  rescue Errno::ENETUNREACH
    nil
  end

  # TODO: this presentation stuff overlaps with the BuildingPresenter. Make the Buildings::MainController use the presenter.
  def full_street_address
    "#{[street_address, city, state].join(' ')} #{postal_code}"
  end

  def architects_list
    architects.map(&:name).join(', ')
  end

  def architects_list=(value)
    self.architects = value.split(',').map(&:strip).map { |item| Architect.find_or_create_by(name: item) }
  end

  def address
    return @address if defined?(@address)

    @address = addresses&.detect(&:is_primary)
  end

  def address_house_number
    address&.house_number
  end

  def address_street_prefix
    address&.prefix
  end

  def address_street_name
    address&.name
  end

  def address_street_suffix
    address&.suffix
  end

  def city
    address&.city
  end

  def address_year_earliest
    address&.year_earliest
  end

  def address_year_latest
    address&.year_latest
  end

  def street_address_for_building_id(year)
    addresses
      .to_a
      .select { |a| a.year.blank? || a.year <= year }
      .sort
      .first
      .address
  end

  def street_address
    addresses.sort_by { |b| b.is_primary? ? -1 : 1 }.map(&:address).join("\n")
  end

  def primary_street_address
    (addresses.detect(&:is_primary) || addresses.first || OpenStruct.new(address: 'No address')).address
  end

  def ensure_primary_address
    addresses.build(is_primary: true) if new_record? && addresses.blank?
  end

  def name_the_house
    return if name.present?

    self.name = primary_street_address
  end
  before_validation :name_the_house

  def neighbors
    lat? ? Building.near([lat, lon], 0.1).where('id<>?', id).limit(4).includes(:addresses) : []
  end

  attr_writer :residents

  def residents
    @residents ||= BuildingResidentsLoader.new(building: self).call
  end

  def families
    @families = residents&.group_by(&:dwelling_number)
  end

  CensusYears.each do |year|
    define_method("families_in_#{year}") do
      send("census_#{year}_records").group_by(&:family_id)
    end
  end

  def frame_type
    ConstructionMaterial.find frame_type_id
  end
  memoize :frame_type

  def lining_type
    ConstructionMaterial.find lining_type_id
  end
  memoize :lining_type

  def building_types
    BuildingType.from_mask(building_types_mask)
  end

  def building_type_ids
    BuildingType.ids_from_mask(building_types_mask)
  end

  def building_type_ids=(ids)
    self.building_types_mask = BuildingType.mask_from_ids(ids)
  end

  private

  def validate_primary_address
    primary_addresses = addresses.to_a.select(&:is_primary)
    if primary_addresses.blank?
      errors.add(:base, 'Primary address missing.')
    elsif primary_addresses.size > 1
      errors.add(:base, 'Multiple primary addresses not allowed.')
    end
  end

  def check_locality
    return if locality_id.present?

    self.locality = Locality.first if Locality.count == 1
  end
end
