# frozen_string_literal: true

class Census1870FormFields < CensusFormFieldConfig
  scope_fields_for 1870
  pre_1880_name_fields

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
  input :father_foreign_born, as: :boolean
  input :mother_foreign_born, as: :boolean
  input :birth_month, as: :radio_buttons, collection: (1..12).map { |m| ["#{m} - #{Date::MONTHNAMES[m]}", m] }
  input :marriage_month, as: :radio_buttons, collection: (1..12).map { |m| ["#{m} - #{Date::MONTHNAMES[m]}", m] }
  input :attended_school, as: :boolean
  input :cannot_read, as: :boolean
  input :cannot_write, as: :boolean

  divider 'Physical and Mental Condition'
  input :deaf_dumb, as: :boolean
  input :blind, as: :boolean
  input :insane, as: :boolean
  input :idiotic, as: :boolean

  divider 'Constitutional Relations'
  input :full_citizen, as: :boolean
  input :denied_citizen, as: :boolean

  additional_fields
end
