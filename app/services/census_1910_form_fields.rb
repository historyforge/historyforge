class Census1910FormFields < CensusFormFields
  divider "Name"

  input :last_name,
               input_html: { autocomplete: 'new-password' },
               hint: -> { name_hint }

  input :first_name,
               input_html: { autocomplete: 'new-password' },
               hint: -> { name_hint }

  input :middle_name,
               input_html: { autocomplete: 'new-password' },
               hint: -> { name_hint }

  input :name_prefix,
               input_html: { autocomplete: 'new-password' },
               hint: -> { name_prefix_hint }

  input :name_suffix,
               input_html: { autocomplete: 'new-password' },
               hint: -> { name_suffix_hint }

  divider "Relation"

  input :relation_to_head,
               input_html: { autocomplete: 'new-password' },
               hint: -> { relation_to_head_hint }

  divider "Personal Description"

  input :sex,
               as: :radio_buttons,
               collection: Census1910Record.sex_choices,
               coded: true,
               hint: -> { sex_hint }

  input :race,
               as: :radio_buttons,
               collection: Census1910Record.race_choices,
               coded: true,
               hint: -> { race_hint }

  input :age, as: :integer, hint: -> { age_hint }

  input :age_months, as: :integer, hint: -> { age_months_hint }

  input :marital_status,
               as: :radio_buttons,
               collection: Census1910Record.marital_status_choices,
               coded: true,
               hint: -> { marital_status_hint }

  input :years_married,
               as: :integer,
               input_html: { min: 0 },
               hint: -> { years_married_hint }

  input :num_children_born,
               as: :integer,
               input_html: { min: 0 },
               hint: -> { num_children_born_hint }

  input :num_children_alive,
               as: :integer,
               input_html: { min: 0 },
               hint: -> { num_children_alive_hint }

  divider "Place of Birth & Citizenship"

  input :pob,
               input_html: {autocomplete: 'new-password'},
               hint: -> { pob_1910_hint(12) }

  input :mother_tongue,
               input_html: {autocomplete: 'new-password'},
               hint: -> { mother_tongue_1910_hint(12) }

  input :pob_father,
               input_html: {autocomplete: 'new-password'},
               hint: -> { pob_1910_hint(13) }

  input :mother_tongue_father,
               input_html: {autocomplete: 'new-password'},
               hint: -> { mother_tongue_1910_hint(13) }

  input :pob_mother,
               input_html: {autocomplete: 'new-password'},
               hint: -> { pob_1910_hint(14) }

  input :mother_tongue_mother,
               input_html: {autocomplete: 'new-password'},
               hint: -> { mother_tongue_1910_hint(14) }

  input :foreign_born,
               as: :boolean,
               hint: -> { foreign_born_1910_hint },
               wrapper_html: { data: { dependents: 'true' } }

  input :year_immigrated,
               as: :integer,
               hint: -> { year_immigrated_hint },
               wrapper_html: { data: { depends_on: :foreign_born } }

  input :naturalized_alien,
               as: :radio_buttons,
               collection: Census1910Record.naturalized_alien_choices,
               coded: true,
               hint: -> { naturalization_hint },
               wrapper_html: { data: { depends_on: :foreign_born } }

  input :language_spoken, hint: -> { language_spoken_hint }

  divider "Occupation, Industry, Education and Employment Status"

  input :profession,
               hint: -> { profession_hint },
               input_html: { autocomplete: 'new-password' }

  input :industry,
               input_html: { autocomplete: 'new-password' },
               hint: -> { industry_hint }

  input :employment,
               as: :radio_buttons,
               collection: Census1910Record.employment_choices,
               coded: true,
               hint: -> { employment_hint }

  input :unemployed,
               as: :boolean,
               hint: -> { boolean_hint(21) }

  input :unemployed_weeks_1909,
               hint: -> { unemployed_weeks_hint }

  input :can_read,
               as: :boolean,
               hint: -> { boolean_hint(23) }

  input :can_write,
               as: :boolean,
               hint: -> { boolean_hint(24) }

  input :attended_school,
               as: :boolean,
               hint: -> { boolean_hint(25) }

  divider "Household Data"

  input :owned_or_rented,
               as: :radio_buttons,
               collection: Census1910Record.owned_or_rented_choices,
               coded: true,
               hint: -> { owned_or_rented_hint }

  input :mortgage,
               as: :radio_buttons,
               collection: Census1910Record.mortgage_choices,
               coded: true,
               hint: -> { owned_or_rented_hint(27) }

  input :farm_or_house,
               as: :radio_buttons,
               collection: Census1910Record.farm_or_house_choices,
               coded: true,
               hint: -> { owned_or_rented_hint(28) }

  input :num_farm_sched,
               as: :integer,
               hint: -> { num_farm_sched_hint }

  divider "More Personal Data"

  input :civil_war_vet,
               as: :radio_buttons,
               label: 'Civil War',
               collection: Census1910Record.civil_war_vet_choices,
               coded: true,
               hint: -> { civil_war_hint }

  input :blind,
               as: :boolean,
               hint: -> { boolean_hint(31) }

  input :deaf_dumb,
               as: :boolean,
               hint: -> { boolean_hint(32) }

end