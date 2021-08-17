class Census1910Record < CensusRecord

  self.table_name = 'census_1910_records'

  belongs_to :locality, inverse_of: :census1910_records

  validates :language_spoken, vocabulary: { name: :language, allow_blank: true }
  validates :mother_tongue, :mother_tongue_father, :mother_tongue_mother, vocabulary: { name: :language, allow_blank: true }
  validates :dwelling_number, presence: true

  auto_strip_attributes :industry, :employment

  define_enumeration :race, %w[W B Mu Ch Jp In Ot]
  define_enumeration :marital_status, %w[S M_or_M1 M2_or_M3 Wd D]

  def year
    1910
  end

  COLUMNS = {
    street_house_number: '2nd Column on the Left',
    street_prefix: '1st Column on the Left',
    street_name: '1st Column on the Left',
    street_suffix: '1st Column on the Left',
    dwelling_number: 1,
    family_id: 2,
    last_name: 3,
    first_name: 3,
    middle_name: 3,
    name_prefix: 3,
    name_suffix: 3,
    relation_to_head: 4,
    race: 6,
    sex: 5,
    age: 7,
    age_months: 7,
    marital_status: 8,
    years_married: 9,
    num_children_born: 10,
    num_children_alive: 11,
    pob: 12,
    mother_tongue: 12,
    pob_father: 13,
    mother_tongue_father: 13,
    pob_mother: 14,
    mother_tongue_mother: 14,
    year_immigrated: 15,
    naturalized_alien: 16,
    language_spoken: 17,
    profession: 18,
    industry: 19,
    employment: 20,
    unemployed: 21,
    unemployed_weeks_1909: 22,
    can_read: 23,
    can_write: 24,
    attended_school: 25,
    owned_or_rented: 26,
    mortgage: 27,
    farm_or_house: 28,
    num_farm_sched: 29,
    civil_war_vet: 30,
    blind: 31,
    dumb: 32
  }.freeze
end
