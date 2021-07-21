class CensusRecord1910Search < CensusRecordSearch
  def default_fields
    %w[census_scope name sex race age marital_status relation_to_head profession industry pob street_address]
  end

  def all_fields
    %w[census_scope page_number page_side line_number county city ward enum_dist street_address locality dwelling_number family_id
      name relation_to_head sex race age marital_status years_married
      num_children_born num_children_alive pob mother_tongue pob_father mother_tongue_father pob_mother mother_tongue_mother
      foreign_born year_immigrated naturalized_alien language_spoken profession industry employment
      unemployed unemployed_weeks_1909 can_read can_write attended_school
      owned_or_rented mortgage farm_or_house num_farm_sched civil_war_vet blind deaf_dumb
      notes latitude longitude
    ]
  end
end
