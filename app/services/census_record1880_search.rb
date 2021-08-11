# frozen_string_literal: true

class CensusRecord1880Search < CensusRecordSearch
  def default_fields
    %w[census_scope name sex race age marital_status relation_to_head occupation pob street_address]
  end

  def all_fields
    %w[
      census_scope page_number page_side line_number
      county city ward enum_dist street_address locality dwelling_number family_id
      name sex race age age_months birth_month
      relation_to_head marital_status just_married occupation unemployed_months
      sick blind deaf_dumb idiotic insane maimed attended_school cannot_read cannot_write
      pob pob_father pob_mother
      notes latitude longitude
    ]
  end

  def entity_class
    Census1880Record
  end
end
