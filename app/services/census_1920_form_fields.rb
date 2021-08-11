# frozen_string_literal: true

class Census1920FormFields < CensusFormFields
  include CensusScopeFormFields

  include CensusNameFields

  divider 'Relation'
  input :relation_to_head

  divider 'Household Data'
  input :owned_or_rented, as: :radio_buttons, coded: true

  input :mortgage, as: :radio_buttons, coded: true

  divider 'Personal Description'
  input :sex, as: :radio_buttons, coded: true
  input :race, as: :radio_buttons_other, coded: true
  input :age, as: :integer, min: 0, max: 130
  input :age_months, as: :integer, min: 0, max: 12
  input :marital_status, as: :radio_buttons, coded: true

  divider 'Citizenship, Education, and Place of Birth'
  input :foreign_born, as: :boolean, dependents: true
  input :year_immigrated, as: :integer, depends_on: :foreign_born
  input :naturalized_alien, as: :radio_buttons, coded: true, depends_on: :foreign_born
  input :year_naturalized, as: :integer, depends_on: :foreign_born
  input :attended_school, as: :boolean
  input :can_read, as: :boolean
  input :can_write, as: :boolean
  input :pob
  input :mother_tongue
  input :pob_father
  input :mother_tongue_father
  input :pob_mother
  input :mother_tongue_mother
  input :can_speak_english, as: :boolean

  divider 'Occupation, Industry, and Class of Worker'
  input :profession
  input :industry
  input :employment, as: :radio_buttons, coded: true
  input :farm_schedule
  input :employment_code

  include CensusAdditionalFormFields
end
