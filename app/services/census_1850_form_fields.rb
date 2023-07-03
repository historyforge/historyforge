# frozen_string_literal: true

class Census1850FormFields < CensusFormFieldConfig
  include CensusScopeFormFields
  include CensusNameFields

  divider 'Personal Description'
  input :age, as: :integer, min: 0, max: 130
  input :age_months, as: :integer, min: 0, max: 12
  input :race, as: :radio_buttons, coded: true
  input :sex, as: :radio_buttons, coded: true
  input :occupation
  input :home_value, as: :integer
  input :pob
  input :foreign_born, as: :boolean
  input :just_married, as: :boolean
  input :attended_school, as: :boolean
  input :cannot_read_write, as: :boolean

  divider 'Physical and Mental Condition - Column 13', hint: <<~DESC
    The enumerator instructions state that in the case of an institution,
    the census taker should indicate the dwelling number and "must write
    after the number, and perpendicularly in the same column (No. 1) the
    nature of such institution—that it is a penitentiary, jail, house of refuge,
    as the case may be; and in column 13, opposite the name of each person,
    he must state the character of the infirmity or misfortune, in the one case,
    and in the other he must state the crime for which each inmate is convicted,
    and of which such person was convicted; and in column No. 3, with the name,
    give the year of conviction". Enter such information as is available here.
  DESC
  input :deaf_dumb, as: :boolean
  input :blind, as: :boolean
  input :insane, as: :boolean
  input :idiotic, as: :boolean
  input :pauper, as: :boolean
  input :convict, as: :boolean
  input :nature_of_misfortune, hint: false
  input :year_of_misfortune, hint: false
  input :institution_name, as: :string, facet: false, hint: false
  input :institution_type, as: :string, facet: false, hint: false

  include CensusAdditionalFormFields
end
