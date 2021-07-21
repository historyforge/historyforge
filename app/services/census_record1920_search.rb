class CensusRecord1920Search < CensusRecordSearch
  def default_fields
    %w{census_scope name sex race age marital_status relation_to_head profession industry pob street_address}
  end

  def all_fields
    %w[census_scope page_number page_side line_number county city ward enum_dist street_address locality dwelling_number family_id
      name relation_to_head owned_or_rented mortgage sex race age marital_status
      foreign_born year_immigrated naturalized_alien year_naturalized
      attended_school can_read can_write
      pob mother_tongue pob_father mother_tongue_father pob_mother mother_tongue_mother
      can_speak_english
      profession industry employment employment_code
      farm_or_house farm_schedule
      notes latitude longitude
    ]
  end
end
