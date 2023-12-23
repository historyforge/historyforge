# frozen_string_literal: true

class NameAuthority < ApplicationRecord
  include PersonNames

  belongs_to :person

  def same_name_as?(census_record)
    census_record.first_name == first_name &&
      census_record.last_name == last_name &&
      census_record.middle_name == middle_name &&
      census_record.name_prefix == name_prefix &&
      census_record.name_suffix == name_suffix
  end
end
