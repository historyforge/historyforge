# frozen_string_literal: true

FactoryBot.define do
  factory(:census1940_record) do
    city { 'Ithaca' }
    county { 'Tompkins' }
    state { 'New York' }
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:middle_name) { |n| "Middle#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    sex { 'M' }
    race { 'W' }
    profession { 'None' }
    family_id { 1 }
    relation_to_head { 'Head' }
    page_number { 1 }
    page_side { 'A' }
    sequence(:line_number) { |n| n + 1 }
    enum_dist { 1 }
    locality
    # mother_tongue { 'English' }
  end
end
