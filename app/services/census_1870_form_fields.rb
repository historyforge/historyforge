# frozen_string_literal: true

class Census1870FormFields < CensusFormFieldConfig
  include CensusScopeFormFields
  include CensusNameFields

  divider 'Personal Description'
  input :age, as: :integer, min: 0, max: 130
  input :age_months, as: :integer, min: 0, max: 12
  input :race, as: :radio_buttons, coded: true
  input :sex, as: :radio_buttons, coded: true
  input :occupation
  input :home_value, as: :integer
  input :personal_value, as: :integer
  input :pob
  input :foreign_born, as: :boolean
  input :father_foreign_born, as: :boolean
  input :mother_foreign_born, as: :boolean
  input :just_born, as: :boolean
  input :just_married, as: :boolean
  input :attended_school, as: :boolean
  input :cannot_read, as: :boolean
  input :cannot_write, as: :boolean

  divider 'Physical and Mental Condition'
  input :deaf_dumb, as: :boolean
  input :blind, as: :boolean
  input :insane, as: :boolean
  input :idiotic, as: :boolean
  input :pauper, as: :boolean
  input :convict, as: :boolean

  divider 'Constitutional Relations'
  input :full_citizen, as: :boolean
  input :denied_citizen, as: :boolean

  include CensusAdditionalFormFields
end
