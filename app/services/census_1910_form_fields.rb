# frozen_string_literal: true

class Census1910FormFields < CensusFormFieldConfig
  scope_fields_for 1910
  name_fields

  divider 'Relation'
  input :relation_to_head

  divider 'Personal Description'
  input :sex, as: :radio_buttons, coded: true
  input :race, as: :radio_buttons_other, coded: true
  input :age, as: :integer, min: 0, max: 130
  input :age_months, as: :integer, min: 0, max: 12
  input :marital_status, as: :radio_buttons, coded: true
  input :years_married, as: :integer, min: 0
  input :num_children_born, as: :integer, min: 0
  input :num_children_alive, as: :integer, min: 0

  divider 'Place of Birth & Citizenship'
  input :pob
  input :mother_tongue
  input :pob_father
  input :mother_tongue_father
  input :pob_mother
  input :mother_tongue_mother
  input :foreign_born, as: :boolean, dependents: true
  input :year_immigrated, as: :integer, depends_on: :foreign_born
  input :naturalized_alien, as: :radio_buttons, coded: true, depends_on: :foreign_born
  input :language_spoken

  divider 'Occupation, Industry, Education and Employment Status'
  input :occupation
  input :industry
  input :employment, as: :radio_buttons, coded: true
  input :unemployed, as: :boolean
  input :unemployed_weeks_1909, min: 0, facet: false
  input :can_read, as: :boolean
  input :can_write, as: :boolean
  input :attended_school, as: :boolean

  divider 'Household Data'
  input :owned_or_rented, as: :radio_buttons, coded: true
  input :mortgage, as: :radio_buttons, coded: true
  input :farm_or_house, as: :radio_buttons, coded: true
  input :num_farm_sched, as: :integer, min: 0, facet: false

  divider 'More Personal Data'
  input :civil_war_vet, as: :radio_buttons, coded: true
  input :blind, as: :boolean
  input :deaf_dumb, as: :boolean

  additional_fields
end
