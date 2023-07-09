# frozen_string_literal: true

class Census1860FormFields < CensusFormFieldConfig
  scope_fields_for 1860
  name_fields

  divider 'Personal Description'
  input :age, as: :integer, min: 0, max: 130
  input :age_months, as: :integer, min: 0, max: 12
  input :sex, as: :radio_buttons, coded: true
  input :race, as: :radio_buttons, coded: true
  input :occupation
  input :home_value, as: :integer
  input :personal_value, as: :integer
  input :pob
  input :foreign_born, as: :boolean
  input :just_married, as: :boolean
  input :attended_school, as: :boolean
  input :cannot_read_write, as: :boolean

  divider 'Physical and Mental Condition - Column 14'
  input :deaf_dumb, as: :boolean
  input :blind, as: :boolean
  input :insane, as: :boolean
  input :idiotic, as: :boolean
  input :pauper, as: :boolean
  input :convict, as: :boolean
  input :nature_of_misfortune, hint: false
  input :year_of_misfortune, hint: false

  additional_fields
end
