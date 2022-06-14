# frozen_string_literal: true

class Census1950FormFields < CensusFormFieldConfig
  include CensusScopeFormFields

  divider 'Household Data'
  input :lives_on_farm, as: :boolean
  input :lives_on_3_acres, as: :boolean
  input :ag_questionnaire_no

  include CensusNameFields

  divider 'Relation'
  input :relation_to_head

  divider 'Personal Description'
  input :race, as: :radio_buttons_other, coded: true
  input :sex, as: :radio_buttons, coded: true
  input :age, as: :integer, min: 0, max: 130
  input :birth_month, as: :radio_buttons, collection: (1..12).map { |m| ["#{m} - #{Date::ABBR_MONTHNAMES[m]}", m] }
  input :marital_status, as: :radio_buttons, coded: true

  divider 'Place of Birth & Naturalization'
  input :pob
  input :foreign_born, as: :boolean
  input :naturalized_alien, as: :radio_buttons, coded: true

  divider 'For Persons 14 Years of Age and Over'
  input :activity_last_week, as: :radio_buttons_other, coded: :activity, other_label: 'Ot - Other', other_type: :number, other_index: -1
  input :worked_last_week, as: :boolean
  input :seeking_work, as: :boolean
  input :employed_absent, as: :boolean
  input :hours_worked, as: :integer, min: 0
  input :occupation, default: 'None'
  input :industry
  input :worker_class, as: :radio_buttons, coded: true
  input :occupation_code
  input :industry_code
  input :worker_class_code

  include CensusAdditionalFormFields

  with_options if: ->(form) { form.editing? || form.object&.supplemental? } do
    divider 'Sample Questions', hint: 'The following questions pertain to persons whose names appear on the line numbers requiring sample question responses.'

    divider 'Residence 1949'
    input :same_house_1949, as: :boolean
    input :on_farm_1949, as: :boolean
    input :same_county_1949, as: :boolean
    input :county_1949
    input :state_1949

    divider 'Place of Birth of Father/Mother'
    input :pob_father
    input :pob_mother

    divider 'Education'
    input :highest_grade, as: :radio_buttons, coded: true
    input :finished_grade, as: :boolean
    input :attended_school, as: :radio_buttons, coded: true

    divider 'Income for this Person in 1949'
    input :weeks_seeking_work, as: :integer, min: 0, max: 52
    input :weeks_worked, as: :integer, min: 0, max: 52
    input :wages_or_salary_self, as: :radio_buttons_other, coded: :wages_or_salary
    input :own_business_self, as: :radio_buttons_other, coded: :wages_or_salary
    input :unearned_income_self, as: :radio_buttons_other, coded: :wages_or_salary

    divider 'Income of Family Members in 1949'
    input :wages_or_salary_family, as: :radio_buttons_other, coded: :wages_or_salary
    input :own_business_family, as: :radio_buttons_other, coded: :wages_or_salary
    input :unearned_income_family, as: :radio_buttons_other, coded: :wages_or_salary

    divider 'For Men'
    input :veteran_ww2, as: :boolean
    input :veteran_ww1, as: :boolean
    input :veteran_other, as: :boolean

    divider 'Additional Sample Questions', hint: 'The rest of this form pertains to the person whose name appears on the last line requiring sample question responses.'
    divider 'If This Person Worked Last Year'
    input :item_20_entries, as: :boolean
    input :last_occupation
    input :last_industry
    input :last_worker_class, as: :radio_buttons, coded: :worker_class

    divider 'If Ever Married'
    input :multi_marriage, as: :boolean
    input :years_married, as: :integer, min: 0, max: 100
    input :newlyweds, as: :boolean

    divider 'For Women'
    input :children_born, as: :integer, min: 0, max: 25
  end
end
