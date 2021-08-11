# frozen_string_literal: true

class Census1900FormFields < CensusFormFieldConfig
  include CensusScopeFormFields

  include CensusNameFields

  divider 'Relation'
  input :relation_to_head

  divider 'Personal Description'
  input :race, as: :radio_buttons, coded: true
  input :sex, as: :radio_buttons, coded: true
  input :birth_month, as: :radio_buttons, collection: (1..12).map { |m| ["#{m} - #{Date::MONTHNAMES[m]}", m] }
  input :birth_year, as: :integer, min: 0
  input :age, as: :integer, min: 0, max: 130
  input :age_months, as: :integer, min: 0, max: 12
  input :marital_status, as: :radio_buttons, coded: true
  input :years_married, as: :integer, min: 0
  input :num_children_born, as: :integer, min: 0
  input :num_children_alive, as: :integer, min: 0

  divider 'Place of Birth & Citizenship'
  input :pob
  input :pob_father
  input :pob_mother
  input :foreign_born, as: :boolean, dependents: true
  input :year_immigrated, as: :integer, depends_on: :foreign_born, min: 0
  input :years_in_us, as: :integer, depends_on: :foreign_born, min: 0
  input :naturalized_alien, as: :radio_buttons, coded: true, depends_on: :foreign_born

  divider 'Occupation, Industry, Education and Employment Status'
  input :profession
  input :industry
  input :unemployed_months, as: :integer, min: 0
  input :attended_school, as: :integer
  input :can_read, as: :boolean
  input :can_write, as: :boolean
  input :can_speak_english, as: :boolean

  divider 'Household Data'
  input :owned_or_rented, as: :radio_buttons, coded: true
  input :mortgage, as: :radio_buttons, coded: true
  input :farm_or_house, as: :radio_buttons, coded: true
  input :farm_schedule, as: :integer

  include CensusAdditionalFormFields
end
