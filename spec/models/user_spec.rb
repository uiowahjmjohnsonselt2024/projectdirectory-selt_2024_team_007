require 'rails_helper.rb'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = User.new(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password")
    expect(user).to be_valid
  end

  it "is not valid without a name" do
    user = User.new(email: "john@example.com", password: "password", password_confirmation: "password")
    expect(user).to_not be_valid
  end

  it "is not valid without an email" do
    user = User.new(name: "John Doe", password: "password", password_confirmation: "password")
    expect(user).to_not be_valid
  end

  it "is not valid with an invalid email format" do
    user = User.new(name: "John Doe", email: "invalid_email", password: "password", password_confirmation: "password")
    expect(user).to_not be_valid
  end

  it "is not valid with a duplicate email" do
    User.create(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password")
    user = User.new(name: "Jane Doe", email: "john@example.com", password: "password", password_confirmation: "password")
    expect(user).to_not be_valid
  end

  it "is not valid with a password shorter than 6 characters" do
    user = User.new(name: "John Doe", email: "john@example.com", password: "short", password_confirmation: "short")
    expect(user).to_not be_valid
  end

  it "is not valid when password and password_confirmation don't match" do
    user = User.new(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "different")
    expect(user).to_not be_valid
  end

  it "creates a session token before saving" do
    user = User.create(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password")
    expect(user.session_token).to_not be_nil
  end
end
