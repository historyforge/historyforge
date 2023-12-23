FactoryBot.define do
  factory :person_name do
    person { nil }
    is_primary { false }
    last_name { "MyString" }
    first_name { "MyString" }
    middle_name { "MyString" }
    name_prefix { "MyString" }
    name_suffix { "MyString" }
  end
end
