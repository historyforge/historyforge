class Person < ApplicationRecord
  include PersonNames
  include PgSearch::Model
  include Flaggable
  include DefineEnumeration

  define_enumeration :sex, %w{M F}
  define_enumeration :race, %w{W B M}

  has_one :census_1900_record, dependent: :nullify
  has_one :census_1910_record, dependent: :nullify
  has_one :census_1920_record, dependent: :nullify
  has_one :census_1930_record, dependent: :nullify
  has_one :census_1940_record, dependent: :nullify
  has_and_belongs_to_many :photographs
  validates :last_name, :sex, :race, presence: true

  before_save :estimate_birth_year
  before_save :estimate_pob

  pg_search_scope :last_name_search,
                  against: :last_name,
                  using: %i[dmetaphone]

  # To make the "Mark n Reviewed" button work for now...
  def reviewed?
    true
  end

  def self.likely_matches_for(record)
    matches = where(sex: record.sex, last_name: record.last_name, first_name: record.first_name).order(:first_name, :middle_name)
    matches = last_name_search(record.last_name).where(sex: record.sex) unless matches.exists?
    matches = where(sex: record.sex, last_name: record.last_name).order(:first_name, :middle_name) unless matches.exists?
    matches = matches.includes(:census_1900_record, :census_1910_record, :census_1920_record, :census_1930_record)
    matches.select { |match| match.census_records.blank? || match.similar_in_age?(record) }
  end

  def self.probable_match_for(record)
    matches = where(sex: record.sex, last_name: record.last_name, first_name: record.first_name).order(:first_name, :middle_name)
    probables = []
    if matches.present?
      matches.each do |match|
        probables << match if match.similar_in_age?(record)
      end
      if probables.any?
        return probables.first if probables.size == 1
        probables.each do |match|
          next if match.census_records.blank?
          match.census_records.each do |match_record|
            score = 0
            score += 1 if match_record.street_address == record.street_address
            score += 1 if match_record.relation_to_head == record.relation_to_head
            score += 1 if match_record.profession == record.profession
            match_record.fellows.each do |match_record_fellow|
              record.fellows.each do |fellow|
                score += 1 if fellow.first_name == match_record_fellow.first_name && fellow.relation_to_head == match_record_fellow.relation_to_head
              end
            end
            return match if score >= 1
          end
        end
      end
    end
    nil
  end

  def similar_in_age?(target)
    return false if target.age.blank?

    (age_in_year(target.year) - target.age).abs <= 2
  end

  def age_in_year(year)
    match = [census_1940_record, census_1930_record, census_1920_record, census_1910_record, census_1900_record].compact.first
    diff = match.year - year
    match.age - diff
  rescue
    -1
  end

  def census_records
    @census_records ||= [census_1940_record, census_1930_record, census_1920_record, census_1910_record, census_1900_record].compact
  end

  def relation_to_head
    census_records.map(&:relation_to_head).uniq.join(', ')
  end

  def profession
    census_records.map(&:profession).uniq.join(', ')
  end

  def address
    census_records.map(&:street_address).uniq.join(', ')
  end

  def estimated_birth_year
    records = census_records&.select { |r| r.age.present? }
    return if records.blank?
    records.map { |r| r.year - r.age }.reduce(&:+) / census_records.size
  end

  private

  def estimate_birth_year
    self.birth_year = estimated_birth_year if birth_year.blank? && is_birth_year_estimated? && census_records.present?
  end

  def estimate_pob
    return if pob.present? || !is_pob_estimated? || census_records.blank?
    pobs = census_records.map(&:pob).compact.uniq
    self.pob = pobs.first if pobs.present?
  end
end
