# frozen_string_literal: true

# Base class for census records.
class CensusRecord < ApplicationRecord
  self.abstract_class = true
  include CensusRecords::Searchable
  include CensusRecords::Addressable
  include Moderation
  include PersonNames
  include Flaggable
  include Versioning

  belongs_to :building, optional: true
  belongs_to :person, optional: true
  has_many :bulk_updated_records, as: :record
  has_many :bulk_updates, through: :bulk_updated_records

  attr_accessor :ensure_building

  validates :first_name, :last_name, :family_id, :relation_to_head, :occupation,
            :page_number, :line_number, :county, :city, :state, :enum_dist,
            presence: true
  validates :page_side, presence: true, if: :page_side?
  validates :age, numericality: { greater_than_or_equal_to: -1, allow_nil: true }
  validate :dont_add_same_person, on: :create
  validates :relation_to_head, vocabulary: { allow_blank: true }
  validates :pob, :pob_father, :pob_mother, vocabulary: { name: :pob, allow_blank: true }

  after_initialize :set_defaults
  before_save :ensure_housing

  after_commit :audit_person_connection, if: :saved_change_to_person_id?

  define_enumeration :page_side, %w[A B], strict: true, if: :page_side?
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

  scope :unhoused, -> { where(building_id: nil) }
  scope :unmatched, -> { where(person_id: nil) }
  scope :in_census_order, -> { order :ward, :enum_dist, :page_number, :page_side, :line_number }

  class_attribute :year

  def self.for_year(year)
    "Census#{year}Record".constantize
  end

  def self.human_name
    "#{year} Census Record"
  end

  def per_side
    50
  end

  def per_page
    100
  end

  def page_side?
    true
  end

  def field_for(field)
    respond_to?(field) ? public_send(field) : '?'
  end

  def set_defaults
    CensusRecords::SetDefaults.run(record: self)
  end

  def dont_add_same_person
    if duplicate_census_scope?
      errors.add :base, 'A record already exists for this census sheet, side, and line number.'
    elsif last_name.present? && likely_matches?
      errors.add :base, 'A person with the same street number, street name, last name, and first name already exists.'
    end
  end

  scope :not_me, ->(record) { record.persisted? ? where.not(id: record.id) : self }
  def duplicate_census_scope?
    self.class.where(locality_id:, ward:, enum_dist:, page_number:, page_side:, line_number:)
        .not_me(self)
        .count
        .positive?
  end

  def likely_matches?
    self.class.where(locality_id:, street_house_number:, street_name:, last_name:, first_name:, age: age || 0)
        .not_me(self)
        .count
        .positive?
  end

  def likely_person_matches
    Person.likely_matches_for(self)
  end
  memoize :likely_person_matches

  def fellows
    CensusRecords::FindFamilyMembers.run!(record: self)
  end
  memoize :fellows

  def ensure_housing
    return unless building_id.blank? && ensure_building == '1' && street_name && city && street_house_number

    self.building = BuildingFromAddress.new(self).perform
  end

  def audit_person_connection
    person_from, person_to = saved_change_to_person_id
    CensusRecords::AuditPersonConnection.run!(person_from:, person_to:, year:, name:)
  end
end
