class Census1930FormFields < CensusFormFields
  divider "Name"
  input :last_name, input_html: { autocomplete: 'new-password' }
  input :first_name, input_html: { autocomplete: 'new-password' }
  input :middle_name, input_html: { autocomplete: 'new-password' }
  input :name_prefix, input_html: { autocomplete: 'new-password' }
  input :name_suffix, input_html: { autocomplete: 'new-password' }

  divider "Relation"
  input :relation_to_head, input_html: { autocomplete: 'new-password' }

  divider "Household Data"
  input :homemaker, as: :boolean, inline_label: 'Yes'
  input :owned_or_rented, as: :radio_buttons, collection: Census1910Record.owned_or_rented_choices, label: 'Home owned or rented', coded: true
  input :home_value, as: :integer, label: 'Value of home or monthly payment', hint: 'Enter 999 for unknown or leave blank if taker left empty'
  input :has_radio, as: :boolean
  input :lives_on_farm, as: :boolean

  divider "Personal Description"
  input :sex, as: :radio_buttons, collection: CensusRecord.sex_choices, coded: true
  input :race, as: :radio_buttons_other, collection: Census1930Record.race_choices, coded: true
  input :age, as: :integer, hint: 'Enter 999 for unknown or leave blank if taker left empty'
  input :age_months, as: :integer, hint: 'Only for children less than 5 years old'
  input :marital_status, as: :radio_buttons, collection: Census1930Record.marital_status_choices, coded: true
  input :age_married, as: :integer, hint: 'Enter 999 for unknown or leave blank if taker left empty'
  input :attended_school, as: :boolean
  input :can_read_write, as: :boolean

  divider "Place of Birth & Citizenship"
  input :pob, input_html: { autocomplete: 'new-password' }
  input :pob_father, input_html: { autocomplete: 'new-password' }
  input :pob_mother, input_html: { autocomplete: 'new-password' }
  input :mother_tongue, input_html: { autocomplete: 'new-password' }
  input :foreign_born, as: :boolean, wrapper_html: { data: { dependents: 'true' } }
  input :year_immigrated, as: :integer, hint: 'Enter 999 for unknown or leave blank if taker left empty', wrapper_html: { data: { depends_on: :foreign_born } }
  input :naturalized_alien, as: :radio_buttons, collection: CensusRecord.naturalized_alien_choices, coded: true, wrapper_html: { data: { depends_on: :foreign_born } }
  input :can_speak_english, as: :boolean

  divider "Occupation, Industry, and Class of Worker"
  input :profession, hint: 'Enter "None" if empty', input_html: { autocomplete: 'new-password' }
  input :industry, input_html: { autocomplete: 'new-password' }
  input :profession_code, input_html: { autocomplete: 'new-password' }
  input :worker_class, label: 'Worker Class', collection: Census1930Record.worker_class_choices, coded: true, as: :radio_buttons
  input :worked_yesterday, as: :boolean
  input :veteran, as: :boolean
  input :war_fought, label: 'What War?', as: :radio_buttons_other, collection: Census1930Record.war_fought_choices, coded: true
  input :farm_schedule, label: 'Farm Number'

end
