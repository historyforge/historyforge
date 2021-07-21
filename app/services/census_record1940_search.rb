class CensusRecord1940Search < CensusRecordSearch
  def default_fields
    %w{census_scope name sex race age marital_status relation_to_head occupation industry pob street_address}
  end

  def all_fields
    %w[census_scope page_number page_side line_number county city ward enum_dist street_address locality family_id
      owned_or_rented home_value lives_on_farm name relation_to_head sex race age marital_status
      attended_school grade_completed pob foreign_born naturalized_alien
      residence_1935_town residence_1935_county residence_1935_state residence_1935_farm
      private_work public_work seeking_work had_job
      no_work_reason private_hours_worked unemployed_weeks
      occupation industry worker_class occupation_code industry_code worker_class_code
      full_time_weeks income had_unearned_income farm_schedule
      pob_father pob_mother mother_tongue veteran veteran_dead war_fought
      soc_sec deductions deduction_rate usual_profession usual_industry usual_worker_class
      usual_occupation_code usual_industry_code usual_worker_class_code
      multi_marriage first_marriage_age children_born
      notes latitude longitude
    ]
  end
end
