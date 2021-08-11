# frozen_string_literal: true

class Census1930FormFields < CensusFormFieldConfig
  include CensusScopeFormFields
  include CensusNameFields

  divider 'Relation'
  input :relation_to_head

  divider 'Household Data'
  input :homemaker, as: :boolean
  input :owned_or_rented, as: :radio_buttons, coded: true
  input :home_value, as: :integer
  input :has_radio, as: :boolean
  input :lives_on_farm, as: :boolean

  divider 'Personal Description'
  input :sex, as: :radio_buttons, coded: true
  input :race, as: :radio_buttons_other, coded: true
  input :age, as: :integer, min: 0, max: 140
  input :age_months, as: :integer, min: 0, max: 12
  input :marital_status, as: :radio_buttons, coded: true
  input :age_married, as: :integer, min: 0, max: 140
  input :attended_school, as: :boolean
  input :can_read_write, as: :boolean

  divider 'Place of Birth & Citizenship'
  input :pob
  input :pob_father
  input :pob_mother
  input :mother_tongue
  input :foreign_born, as: :boolean, dependents: true
  input :year_immigrated, as: :integer, depends_on: :foreign_born, min: 0
  input :naturalized_alien, as: :radio_buttons, coded: true, depends_on: :foreign_born, min: 0
  input :can_speak_english, as: :boolean

  divider 'Occupation, Industry, and Class of Worker'
  input :profession
  input :industry
  input :profession_code
  input :worker_class, coded: true, as: :radio_buttons
  input :worked_yesterday, as: :boolean
  input :veteran, as: :boolean
  input :war_fought, as: :radio_buttons_other, coded: true
  input :farm_schedule

  include CensusAdditionalFormFields
end
