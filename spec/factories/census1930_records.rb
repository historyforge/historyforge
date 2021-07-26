FactoryBot.define do
  factory(:census1930_record) do
    city { 'Ithaca' }
    county { 'Tompkins' }
    state { 'New York' }
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sex { 'M' }
    race { 'W' }
    profession { 'None' }
    family_id { 1 }
    relation_to_head { 'Head' }
    page_number { 1 }
    page_side { 'A' }
    line_number { 1 }
    enum_dist { 1 }
    locality
    dwelling_number { 1 }
    mother_tongue { 'English' }
  end
end
