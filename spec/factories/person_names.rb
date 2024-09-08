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
#  sortable_name   :string
#
# Indexes
#
#  index_person_names_on_person_id        (person_id)
#  index_person_names_on_searchable_name  (searchable_name) USING gin
#  person_names_primary_name_index        (person_id,is_primary)
#
FactoryBot.define do
  factory :person_name do
    person { nil }
    last_name { Faker::Name.last_name }
    middle_name { Faker::Name.middle_name }
  end
end
