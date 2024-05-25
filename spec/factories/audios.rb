FactoryBot.define do
  factory :audio do
    created_by { nil }
    building { nil }
    description { "MyText" }
    creator { "MyString" }
    date_text { "MyString" }
    date_start { "2024-05-25" }
    date_end { "2024-05-25" }
    location { "MyString" }
    identifier { "MyString" }
    notes { "MyText" }
    latitude { "9.99" }
    longitude { "9.99" }
    reviewed_by { nil }
    reviewed_at { "2024-05-25 17:18:56" }
    date_type { 1 }
    caption { "MyText" }
  end
end
