class CensusRecord < ApplicationRecord

  self.abstract_class = true

  include AutoStripAttributes
  include DefineEnumeration
  include Moderation
  include PersonNames
  include PgSearch::Model
  include Flaggable

  belongs_to :building, optional: true
  belongs_to :person, optional: true
  has_many :bulk_updated_records, as: :record
  has_many :bulk_updates, through: :bulk_updated_records

  attr_accessor :ensure_building
  before_save :ensure_housing
  before_save :match_to_person

  before_validation :clean_enum_dist
  validates :first_name, :last_name, :family_id, :relation_to_head, :profession,
            :page_number, :page_side, :line_number, :county, :city, :state, :enum_dist,
            presence: true
  validates :age, numericality: {greater_than_or_equal_to: -1, allow_nil: true}
  validate :dont_add_same_person, on: :create
  validates :relation_to_head, vocabulary: { allow_blank: true }
  validates :pob, :pob_father, :pob_mother, vocabulary: { name: :pob, allow_blank: true }
  # validates :person_id, uniqueness: { allow_nil: true }

  after_initialize :set_defaults

  auto_strip_attributes :first_name, :middle_name, :last_name, :street_house_number, :street_name,
                        :street_prefix, :street_suffix, :apartment_number, :profession, :name_prefix, :name_suffix

  define_enumeration :page_side, %w{A B}, true
  define_enumeration :street_prefix, %w{N S E W}
  define_enumeration :street_suffix, %w{St Rd Ave Blvd Pl Terr Ct Pk Tr Dr Hill Ln Way}.sort
  define_enumeration :sex, %w{M F}
  define_enumeration :race, %w{W B M}
  define_enumeration :marital_status, %w{S M Wd D}
  define_enumeration :naturalized_alien, %w{Na Pa Al}
  define_enumeration :employment, %w{W Emp OA}
  define_enumeration :owned_or_rented, %w{O R Neither}
  define_enumeration :mortgage, %w{M F}
  define_enumeration :farm_or_house, %w{F H}
  define_enumeration :civil_war_vet, %w{UA UN CA CN}

  attr_accessor :comment
  has_paper_trail meta: { comment: :comment }

  multisearchable against: :name,
                  using: {
                      tsearch: { prefix: true, any_word: true },
                      trigram: {}
                  },
                  if: :reviewed?

  ransacker :name, formatter: proc { |v| v.mb_chars.downcase.to_s } do |parent|
    Arel::Nodes::NamedFunction.new('LOWER',
                                   [Arel::Nodes::NamedFunction.new('concat_ws',
                                                                   [Arel::Nodes::Quoted.new(' '),
                                                                    parent.table[:name_prefix],
                                                                    parent.table[:first_name],
                                                                    parent.table[:middle_name],
                                                                    parent.table[:last_name],
                                                                    parent.table[:name_suffix]
                                                                   ])])
  end

  ransacker :street_address, formatter: proc { |v| (ReverseStreetConversion.convert(v).to_s).mb_chars.downcase.to_s } do |parent|
    Arel::Nodes::NamedFunction.new('LOWER',
                                   [Arel::Nodes::NamedFunction.new('concat_ws',
                                                                   [Arel::Nodes::Quoted.new(' '),
                                                                    parent.table[:street_house_number],
                                                                    parent.table[:street_prefix],
                                                                    parent.table[:street_name],
                                                                    parent.table[:street_suffix]
                                                                   ])])
  end

  scope :unhoused, -> { where(building_id: nil) }
  scope :unmatched, -> { where(person_id: nil) }

  def per_side
    50
  end

  def per_page
    100
  end

  def field_for(field)
    respond_to?(field) ? public_send(field) : '?'
  end

  def set_defaults
    return if persisted?

    self.city ||= AppConfig.city
    self.county ||= AppConfig.county
    self.state ||= AppConfig.state
    self.pob ||= AppConfig.pob

    # Don't autofill these for 1940 because they are supplemental only
    return if year == 1940

    self.pob_mother ||= AppConfig.pob
    self.pob_father ||= AppConfig.pob
  end

  def clean_enum_dist
    write_attribute(:enum_dist, enum_dist.sub(/\A\d+?\W/, '')) if enum_dist.present?
  end

  def dont_add_same_person
    return if persisted? || !likely_matches?

    errors.add :last_name, 'A person with the same street number, street name, last name, and first name is already in the system.'
  end

  def likely_matches?
    self.class.ransack(
      street_house_number_eq: street_house_number,
      street_name_eq: street_name,
      last_name_eq: last_name,
      first_name_eq: first_name,
      age_eq: age || 0
    ).result.count > 0
  end

  def street_address
    [street_house_number, street_prefix, street_name, street_suffix, apartment_number ? "Apt. #{apartment_number}" : nil].compact.join(' ')
  end

  def latitude
    building.andand.lat
  end

  def longitude
    building.andand.lon
  end

  def fellows
    return @fellows if defined?(@fellows)

    options = {
      family_id_eq: family_id,
      page_number_gteq: page_number - 1,
      page_number_lteq: page_number + 1
    }

    if building_id.present?
      options[:building_id_eq] = building_id
    elsif dwelling_number.present?
      options[:dwelling_number_eq] = dwelling_number
    end

    @fellows = self.class.where('id<>?', id).ransack(options).result
  end

  def buildings_on_street
    return [] unless (street_name.present? && city.present?)
    return @buildings_on_street if defined?(@buildings_on_street)

    @buildings_on_street = BuildingsOnStreet.new(self).perform
  end

  def ensure_housing
    return unless (building_id.blank? && ensure_building == '1' && street_name.present? && city.present? && street_house_number.present?)

    self.building = BuildingFromAddress.new(self).perform
  end

  def year
    raise 'Need a year!'
  end

  def match_to_person!
    match_to_person
    update_column :person_id, person.id if person
  end

  def match_to_person
    return if person_id.present?

    match = Person.probable_match_for(self)
    if match
      self.person = match
    else
      generate_person_record!
    end
  end

  def unmarried_female?
    sex == 'F' && %w{S W D}.include?(marital_status)
  end

  def generate_person_record!
    build_person
    person.name_prefix = name_prefix
    person.name_suffix = name_suffix
    person.first_name = first_name
    person.middle_name = middle_name
    person.last_name = last_name
    person.sex = sex
    person.race = race
    person.save
  end
end
