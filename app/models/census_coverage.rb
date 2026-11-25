# == Schema Information
#
# Table name: census_coverages
#
#  id                :integer          not null, primary key
#  locality_id       :integer          not null
#  census_year       :integer          not null
#  expected_records  :integer          not null
#  target_basis      :string           not null
#  source            :string           not null
#  scope_note        :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  verified_at       :datetime
#  verification_note :text
#  verified_by_id    :integer
#
# Indexes
#
#  index_census_coverages_on_locality_id_and_census_year  (locality_id,census_year) UNIQUE
#

# frozen_string_literal: true

class CensusCoverage < ApplicationRecord
  TARGET_BASES = ['Published population', 'Schedule count', 'Estimate'].freeze

  belongs_to :locality, inverse_of: :census_coverages
  belongs_to :verified_by, class_name: 'User', optional: true

  validates :census_year, inclusion: { in: CensusYears::YEARS }, uniqueness: { scope: :locality_id }
  validates :expected_records, numericality: { only_integer: true, greater_than: 0 }
  validates :target_basis, inclusion: { in: TARGET_BASES }
  validates :source, presence: true
  validates :verification_note, presence: true, if: :verified_complete?

  def verified_complete?
    verified_at.present?
  end

  def set_verification(complete:, verifier:)
    if complete
      return if verified_complete?

      self.verified_at = Time.current
      self.verified_by = verifier
    else
      self.verified_at = nil
      self.verified_by = nil
      self.verification_note = nil
    end
  end
end
