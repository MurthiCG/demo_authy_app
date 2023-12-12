FactoryBot.define do
  factory :user do
  	name { Faker::Name.name }
  	email { Faker::Internet.email }
  	password { "Password@123" }
  	confirm_password { "Password@123" }
  	confirmed_at {Time.zone.now - 1.day}
  	confirm_token { SecureRandom.urlsafe_base64 }
  	authy_enabled { true }
  end
end