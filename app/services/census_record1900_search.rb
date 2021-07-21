class CensusRecord1900Search < CensusRecordSearch
  def default_fields
    %w[census_scope name sex race age marital_status relation_to_head profession pob street_address]
  end

  def all_fields
    %w[census_scope page_number page_side line_number county city ward enum_dist street_address locality dwelling_number family_id
      name relation_to_head sex race age birth_month birth_year marital_status years_married
      num_children_born num_children_alive pob pob_father pob_mother foreign_born year_immigrated years_in_us
      naturalized_alien profession industry
      unemployed_months attended_school can_read can_write can_speak_english
      owned_or_rented mortgage farm_or_house farm_schedule
      notes latitude longitude
    ]
  end
end
