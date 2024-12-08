# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
User.destroy_all
User.create!(
  name: "TestUser",
  email: "t@t.t",
  password: "password",
  password_confirmation: "password",
  session_token: SecureRandom.urlsafe_base64,
  reset_digest: nil,
  reset_sent_at: nil,
  uid: nil
)

user = User.find_or_create_by(email: 'admin@example.com') do |u|
  u.name = 'Admin'
  u.password = 'password'
  u.password_confirmation = 'password'
  u.session_token = SecureRandom.urlsafe_base64
  u.reset_digest = nil
  u.reset_sent_at = nil
  u.uid = nil
end

# Create some sample games
5.times do |i|
  game = Game.create!(
    name: "Sample Game #{i + 1}",
    join_code: "GAME#{format('%02d', i + 1)}", # Ensures two digits
    owner: user,
    current_turn_user: user
  )
  game.game_users.create!(user: user, health: 100)
end

puts "Seeded #{Game.count} games."

