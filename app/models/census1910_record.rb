class Census1910Record < CensusRecord

  self.table_name = 'census_1910_records'

  belongs_to :locality, inverse_of: :census1910_records

  validates :language_spoken, vocabulary: { name: :language, allow_blank: true }
  validates :mother_tongue, :mother_tongue_father, :mother_tongue_mother, vocabulary: { name: :language, allow_blank: true }
  validates :dwelling_number, presence: true

  auto_strip_attributes :industry, :employment

  define_enumeration :race, %w{W B Mu Ch Jp In Ot}
  define_enumeration :marital_status, %w{S M_or_M1 M2_or_M3 Wd D}

  def year
    1910
  end

  def self.folder_name
    'census_records_nineteen_ten'
  end
end
