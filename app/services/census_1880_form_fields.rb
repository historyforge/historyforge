# frozen_string_literal: true

class Census1880FormFields < CensusFormFieldConfig
  include CensusScopeFormFields

  include CensusNameFields

  divider 'Personal Description'
  input :race, as: :radio_buttons, coded: true
  input :sex, as: :radio_buttons, coded: true
  input :age, as: :integer, min: 0, max: 130
  input :age_months, as: :integer, min: 0, max: 12
  input :birth_month, as: :radio_buttons, collection: (1..12).map { |m| ["#{m} - #{Date::MONTHNAMES[m]}", m] }
  input :relation_to_head
  input :marital_status, as: :radio_buttons, coded: true
  input :just_married, as: :boolean

  divider 'Occupation'
  input :occupation
  input :unemployed_months, as: :integer, min: 0

  divider 'Physical and Mental Condition'
  input :sick
  input :blind, as: :boolean
  input :deaf_dumb, as: :boolean
  input :idiotic, as: :boolean
  input :insane, as: :boolean
  input :maimed, as: :boolean

  divider 'Education'
  input :attended_school, as: :boolean
  input :cannot_read, as: :boolean
  input :cannot_write, as: :boolean

  divider 'Place of Birth & Citizenship'
  input :pob
  input :pob_father
  input :pob_mother
  input :foreign_born, as: :boolean

  include CensusAdditionalFormFields
end
