class Census1900Record < CensusRecord

  self.table_name = 'census_1900_records'

  belongs_to :locality, inverse_of: :census1900_records

  validates :attended_school, :years_in_us, :years_married,
            :num_children_born, :num_children_alive, :unemployed_months,
            :birth_month, :birth_year, :age, :age_months,
            numericality: { greater_than_or_equal_to: -1, allow_blank: true }

  validates :language_spoken, vocabulary: { name: :language, allow_blank: true }
  validates :dwelling_number, presence: true

  auto_strip_attributes :industry

  define_enumeration :race, %w{W B Ch Jp In}

  def year
    1900
  end

  def self.folder_name
    'census_records_nineteen_aught'
  end

  def birth_month=(value)
    value = 999 if value == 'unknown'
    write_attribute(:birth_month, value)
  end

  def birth_month
    value = read_attribute(:birth_month)
    value == 999 ? 'unknown' : value
  end
end
