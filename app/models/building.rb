class Building < ApplicationRecord
  include AutoStripAttributes
  include Moderation
  include DefineEnumeration
  include Flaggable

  define_enumeration :address_street_prefix, %w{N S E W}
  define_enumeration :address_street_suffix, %w{St Rd Ave Blvd Pl Terr Ct Pk Tr Dr Hill Ln Way}.sort

  has_many :addresses, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: proc { |p| p['name'].blank? }

  has_and_belongs_to_many :architects
  has_and_belongs_to_many :building_types, join_table: :buildings_building_types
  belongs_to :frame_type, class_name: 'ConstructionMaterial', optional: true
  belongs_to :lining_type, class_name: 'ConstructionMaterial', optional: true

  has_many :census_1900_records, dependent: :nullify, class_name: 'Census1900Record'
  has_many :census_1910_records, dependent: :nullify, class_name: 'Census1910Record'
  has_many :census_1920_records, dependent: :nullify, class_name: 'Census1920Record'
  has_many :census_1930_records, dependent: :nullify, class_name: 'Census1930Record'
  has_many :census_1940_records, dependent: :nullify, class_name: 'Census1940Record'

  has_and_belongs_to_many :photos, class_name: 'Photograph', dependent: :nullify

  validates :name, presence: true, length: { maximum: 255 }
  # validates :address_house_number, presence: true, if: :residence?
  validates :year_earliest, :year_latest, numericality: { minimum: 1500, maximum: 2100, allow_nil: true }
  validate :validate_primary_address

  delegate :name, to: :frame_type, prefix: true, allow_nil: true
  delegate :name, to: :lining_type, prefix: true, allow_nil: true

  scope :as_of_year, -> (year) { where("(year_earliest is null and year_latest is null) or (year_earliest<=:year and (year_latest is null or year_latest>=:year)) or (year_earliest is null and year_latest>=:year)", year: year)}
  scope :as_of_year_eq, -> (year) { where("(year_earliest<=:year and (year_latest is null or year_latest>=:year)) or (year_earliest is null and year_latest>=:year)", year: year)}
  scope :without_residents, -> {
    joins("LEFT OUTER JOIN census_1900_records ON census_1900_records.building_id=buildings.id")
      .joins("LEFT OUTER JOIN census_1910_records ON census_1910_records.building_id=buildings.id")
      .joins("LEFT OUTER JOIN census_1920_records ON census_1920_records.building_id=buildings.id")
      .joins("LEFT OUTER JOIN census_1930_records ON census_1930_records.building_id=buildings.id")
      .joins("LEFT OUTER JOIN census_1940_records ON census_1940_records.building_id=buildings.id")
      .joins(:building_types)
      .where("census_1900_records.id IS NULL AND census_1910_records.id IS NULL AND census_1920_records.id IS NULL AND census_1930_records.id IS NULL AND census_1940_records.id IS NULL")
      .where(building_types: { name: 'residence' }) }
  scope :by_street_address, -> {
    left_outer_joins(:addresses)
      .order("addresses.name asc, addresses.prefix asc, addresses.house_number asc")
  }

  def self.ransackable_scopes(auth_object=nil)
    %i{as_of_year without_residents as_of_year_eq}
  end

  has_paper_trail

  Geocoder.configure(
    timeout: 2,
    use_https: true,
    lookup: :google,
    api_key: AppConfig.geocoding_key
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

  def field_for(field)
    respond_to?(field) ? public_send(field) : '?'
  end

  alias_attribute :latitude, :lat
  alias_attribute :longitude, :lon

  def has_proper_name?
    name && (address_house_number.blank? || !name.include?(address_house_number))
  end

  def residence?
    building_types.include?(BuildingType.find_by(name: 'residence'))
  end

  def full_street_address
    "#{[street_address, city, state].join(' ')} #{postal_code}"
  end

  def do_the_geocode
    begin
      geocode
    rescue Errno::ENETUNREACH
      nil
    end
  end

  def architects_list
    architects.map(&:name).join(', ')
  end

  def architects_list=(value)
    self.architects = value.split(',').map(&:strip).map {|item| Architect.where(name: item).first_or_create }
  end

  def building_type_name
    building_types.map(&:name).join('/')
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

  def street_address
    addresses.sort_by { |b| b.is_primary? ? -1 : 1 }.map(&:address).join("\n")
  end

  def primary_street_address
    (addresses.detect(&:is_primary) || addresses.first || OpenStruct.new(address: 'No address')).address
  end

  def ensure_primary_address
    addresses.build(is_primary: true) if new_record? && addresses.blank?
  end
  # after_initialize :ensure_primary_address

  def name_the_house
    return if name.present?

    self.name = primary_street_address
  end
  before_validation :name_the_house

  def neighbors
    lat? ? Building.near([lat, lon], 0.1).where('id<>?', id).limit(4) : []
  end

  attr_accessor :residents

  def with_filtered_residents(year, params)
    if year.present?
      people_class = "Census#{year}Record".constantize
      people = people_class.where.not(reviewed_at: nil)
      if params.present?
        params = JSON.parse(params) if params.is_a?(String)
        q = params.inject({}) {|hash, item|
          hash[item[0].to_sym] = item[1] if item[1].present?
          hash
        }
        @residents = people.where(building_id: id).ransack(q).result
      end
    end
  end

  def with_residents
    @residents = [1900, 1910, 1920, 1930, 1940].map { |year| send("census_#{year}_records").to_a }.flatten
    self
  end

  def families
    @families = if residents
      residents.group_by(&:dwelling_number)
    else
      nil
    end
  end

  def families_in_1900
    census_1900_records.group_by(&:dwelling_number)
  end

  def families_in_1910
    census_1910_records.group_by(&:dwelling_number)
  end

  def families_in_1920
    census_1920_records.group_by(&:dwelling_number)
  end

  def families_in_1930
    census_1930_records.group_by(&:dwelling_number)
  end

  def families_in_1940
    census_1940_records.group_by(&:family_id)
  end

  private

  # FIXME: This doesn't work
  def validate_primary_address
    primary_addresses = addresses.to_a.select(&:is_primary)
    if primary_addresses.blank?
      errors.add(:base, 'Primary address missing.')
    elsif primary_addresses.size > 1
      primary_addresses.each do |address|
        address.errors.add(:is_primary, 'must be unique.')
      end
    end
  end
end
