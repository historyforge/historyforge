# frozen_string_literal: true

class Census1880Record < CensusRecord
  belongs_to :locality, inverse_of: :census1880_records
  define_enumeration :race, %w[W B Mu Ch In]
  alias_attribute :profession, :occupation
  def year
    1880
  end
end
