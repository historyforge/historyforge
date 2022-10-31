FactoryBot.define do
  factory :audit_log do
    loggable_type { "MyString" }
    loggable_id { 1 }
    logger_id { 1 }
    message { "MyString" }
  end
end
