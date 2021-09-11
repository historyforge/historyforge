# frozen_string_literal: true

class Census1940FormFields < CensusFormFieldConfig
  include CensusScopeFormFields

  divider 'Household Data'
  input :owned_or_rented,as: :radio_buttons, coded: true
  input :home_value, as: :integer
  input :lives_on_farm, as: :boolean

  include CensusNameFields

  divider 'Relation'
  input :relation_to_head

  divider 'Personal Description'
  input :sex,as: :radio_buttons, coded: true
  input :race,as: :radio_buttons_other, coded: true
  input :age, as: :integer, min: 0, max: 130
  input :age_months, as: :integer, min: 0, max: 12
  input :marital_status,as: :radio_buttons, coded: true

  divider 'Education'
  input :attended_school, as: :boolean
  input :grade_completed, as: :radio_buttons

  divider 'Place of Birth & Citizenship'
  input :pob
  input :foreign_born, as: :boolean
  input :naturalized_alien, as: :radio_buttons, coded: true

  divider 'Residence, April 1, 1935'
  input :residence_1935_town
  input :residence_1935_county
  input :residence_1935_state
  input :residence_1935_farm, as: :boolean

  divider 'For Persons 14 Years Old and Over - Employment Status'
  input :private_work, as: :boolean
  input :public_work, as: :boolean
  input :seeking_work, as: :boolean
  input :had_job, as: :boolean

  divider 'For Persons Answering "No" to the Above Questions'
  input :no_work_reason, as: :radio_buttons, coded: true

  divider 'If "Yes" to Private Work'
  input :private_hours_worked, as: :integer

  divider 'If "Yes" to Public Work or Seeking Work'
  input :unemployed_weeks, as: :integer, min: 0

  divider 'Occupation, Industry, and Class of Worker'
  input :occupation
  input :industry
  input :worker_class, coded: true, as: :radio_buttons
  input :occupation_code
  input :industry_code
  input :worker_class_code
  input :full_time_weeks, as: :integer, min: 0

  divider 'Income in 1939 (12 months ending Dec. 31, 1939)'
  input :income, as: :integer, min: 0
  input :had_unearned_income, as: :boolean
  input :farm_schedule

  include CensusAdditionalFormFields

  with_options if: ->(form) { form.editing? || form.object&.supplemental? } do
    divider 'Supplemental Questions', hint: 'The rest of this form pertains to persons whose names appear on the line numbers requiring supplementary question responses.'

    divider 'Place of Birth of Father/Mother & Mother Tongue'
    input :pob_father, facet: false
    input :pob_mother, facet: false
    input :mother_tongue, facet: false

    divider 'Veteran'
    input :veteran, as: :boolean, dependents: true, facet: false
    input :veteran_dead, as: :boolean, dependents: true, facet: false
    input :war_fought,
          as: :radio_buttons_other,
          other_label: 'Ot - Other war or expedition',
          coded: true,
          depends_on: :veteran, facet: false

    divider 'Social Security'
    input :soc_sec, as: :boolean, facet: false
    input :deductions, as: :boolean, facet: false
    input :deduction_rate, coded: true, as: :radio_buttons, facet: false

    divider 'Usual Employment'
    input :usual_occupation, facet: false
    input :usual_industry, facet: false
    input :usual_worker_class, as: :radio_buttons, coded: true, collection: Census1940Record.worker_class_choices, facet: false
    input :usual_occupation_code, facet: false
    input :usual_industry_code, facet: false
    input :usual_worker_class_code, facet: false

    divider 'Women'
    input :multi_marriage, as: :boolean, facet: false
    input :first_marriage_age, min: 0, facet: false
    input :children_born, min: 0, facet: false
  end
end
