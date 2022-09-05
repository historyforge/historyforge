# frozen_string_literal: true

class CensusRecord < ApplicationRecord

  self.abstract_class = true

  include AutoStripAttributes
  include AutoUpcaseAttributes
  include DefineEnumeration
  include Moderation
  include PersonNames
  include PgSearch::Model
  include Flaggable
  include Versioning

  belongs_to :building, optional: true
  belongs_to :person, optional: true
  has_many :bulk_updated_records, as: :record
  has_many :bulk_updates, through: :bulk_updated_records

  attr_accessor :ensure_building

  validates :first_name, :last_name, :family_id, :relation_to_head, :profession,
            :page_number, :line_number, :county, :city, :state, :enum_dist,
            :age, :race, :sex,
            presence: true
  validates :page_side, presence: true, if: :has_page_side?
  validates :age, numericality: { greater_than_or_equal_to: -1, allow_nil: true }
  validate :dont_add_same_person, on: :create
  validates :relation_to_head, vocabulary: { allow_blank: true }
  validates :pob, :pob_father, :pob_mother, vocabulary: { name: :pob, allow_blank: true }

  after_initialize :set_defaults
  before_save :ensure_housing

  auto_strip_attributes :first_name, :middle_name, :last_name, :street_house_number, :street_name,
                        :street_prefix, :street_suffix, :apartment_number, :profession, :name_prefix, :name_suffix

  define_enumeration :page_side, %w[A B], strict: true, if: :has_page_side?
  define_enumeration :street_prefix, STREET_PREFIXES
  define_enumeration :street_suffix, STREET_SUFFIXES
  define_enumeration :sex, %w[M F]
  define_enumeration :race, %w[W B M]
  define_enumeration :marital_status, %w[S M Wd D]
  define_enumeration :naturalized_alien, %w[Na Pa Al]
  define_enumeration :employment, %w[W Emp OA]
  define_enumeration :owned_or_rented, %w[O R Neither]
  define_enumeration :mortgage, %w[M F]
  define_enumeration :farm_or_house, %w[F H]
  define_enumeration :civil_war_vet, %w[UA UN CA CN]

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

  def self.for_year(year)
    "Census#{year}Record".constantize
  end

  def per_side
    50
  end

  def per_page
    100
  end

  def has_page_side?
    true
  end

  def field_for(field)
    respond_to?(field) ? public_send(field) : '?'
  end

  def set_defaults
    return if persisted?

    self.city ||= AppConfig[:city]
    self.county ||= AppConfig[:county]
    self.state ||= AppConfig[:state]
    self.pob ||= AppConfig[:pob]

    # Don't autofill these for 1940 because they are supplemental only
    return if year >= 1940

    self.pob_mother ||= AppConfig[:pob]
    self.pob_father ||= AppConfig[:pob]
  end

  def dont_add_same_person
    return if persisted? || !likely_matches? || last_name.blank?

    errors.add :last_name, 'A person with the same street number, street name, last name, and first name is already in the system.'
  end

  def likely_matches?
    self.class.ransack(
      street_house_number_eq: street_house_number,
      street_name_eq: street_name,
      last_name_eq: last_name,
      first_name_eq: first_name,
      age_eq: age || 0
    ).result.count.positive?
  end

  def street_address
    [street_house_number, street_prefix, street_name, street_suffix, apartment_number ? "Apt. #{apartment_number}" : nil].compact.join(' ')
  end

  def latitude
    building&.lat
  end

  def longitude
    building&.lon
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

    @fellows = self.class.where.not(id: id).ransack(options).result
  end

  def ensure_housing
    return unless (building_id.blank? && ensure_building == '1' && street_name.present? && city.present? && street_house_number.present?)

    self.building = BuildingFromAddress.new(self).perform
  end

  def year
    raise 'Need a year!'
  end

  def connect_to_person_record
    MatchCensusToPersonRecordJob.new.perform(year, id)
  end
end
