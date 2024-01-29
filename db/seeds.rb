# frozen_string_literal: true
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user_data = {
  name: "demo",
  email: "testing@demo.com",
  password: "demo@1234",
  confirm_token: SecureRandom.urlsafe_base64,
  confirmed_at: Date.today - 1.day,
 }


User.create(user_data) if User.count == 0
