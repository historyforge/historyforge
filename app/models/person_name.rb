# frozen_string_literal: true

# == Schema Information
#
# Table name: person_names
#
#  id              :bigint           not null, primary key
#  person_id       :bigint           not null
#  is_primary      :boolean
#  last_name       :string
#  first_name      :string
#  middle_name     :string
#  name_prefix     :string
#  name_suffix     :string
#  searchable_name :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_person_names_on_person_id        (person_id)
#  index_person_names_on_searchable_name  (searchable_name) USING gist
#  person_names_primary_name_index        (person_id,is_primary)
#
class PersonName < ApplicationRecord
  include PersonNames

  belongs_to :person

  scope :primary, -> { where(is_primary: true) }

  def same_name_as?(census_record)
    census_record.first_name == first_name &&
      census_record.last_name == last_name
  end
end
