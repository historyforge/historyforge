class Census1940SupplementalFormFields < CensusFormFields
  divider "Supplemental Questions"

  input :pob_father,
               input_html: { autocomplete: 'new-password' },
               hint: -> { pob_1940_hint(36) }

  input :pob_mother,
               input_html: { autocomplete: 'new-password' },
               hint: -> { pob_1940_hint(37) }

  input :mother_tongue,
               input_html: { autocomplete: 'new-password' },
               hint: 'Column 38. Enter as written.'

  input :veteran,
               as: :boolean,
               wrapper_html: { data: { dependents: 'true' } },
               hint: 'Column 39. Check box if the response is yes.'

  input :veteran_dead,
               as: :boolean,
               wrapper_html: { data: { dependents: 'true' } },
               hint: 'Column 40. Check box if the answer is yes.'

  input :war_fought,
               label: 'What War?',
               as: :radio_buttons_other,
               other_label: 'Ot - Other war or expedition',
               collection: Census1940Record.war_fought_choices,
               coded: true,
               wrapper_html: { data: { depends_on: :veteran } },
               hint: 'Column 41. Check the box that corresponds to the answer indicated.'

  input :soc_sec,
               as: :boolean,
               hint: 'Column 42. Check box if the answer is yes.'

  input :deductions,
               as: :boolean,
               hint: 'Column 43. Check box if the answer is yes.'

  input :deduction_rate,
               collection: Census1940Record.deduction_rate_choices,
               coded: true,
               as: :radio_buttons,
               hint: 'Column 44. Check the box that corresponds to the answer indicated.'

  input :usual_profession,
               input_html: { autocomplete: 'new-password' },
               hint: 'Column 45. Enter as written.'

  input :usual_industry,
               input_html: { autocomplete: 'new-password' },
               hint: 'Column 46. Enter as written.'

  input :usual_worker_class,
               collection: Census1940Record.worker_class_choices,
               coded: true,
               as: :radio_buttons,
               hint: 'Column 47. Check the box that corresponds to the answer indicated.'

  input :usual_occupation_code,
               input_html: { autocomplete: 'new-password' },
               hint: -> { occupation_code_hint('J') }

  input :usual_industry_code,
               input_html: { autocomplete: 'new-password' },
               hint: -> { occupation_code_hint('J') }

  input :usual_worker_class_code,
               input_html: { autocomplete: 'new-password' },
               hint: -> { occupation_code_hint('J') }

  input :multi_marriage,
               as: :boolean,
               hint: 'Column 48. Enter as written. Women only please!'

  input :first_marriage_age,
               hint: 'Column 49. Enter as written. Women only please!'

  input :children_born,
               hint: 'Column 50. Enter as written. Women only please!'

end
