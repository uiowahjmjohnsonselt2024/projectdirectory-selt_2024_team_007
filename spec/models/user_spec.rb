require 'rails_helper.rb'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = User.new(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password")
    expect(user).to be_valid
  end

  it "is not valid without a name" do
    user = User.new(email: "john@example.com", password: "password", password_confirmation: "password")
    expect(user).to_not be_valid
  end

  it "is not valid without an email" do
    user = User.new(name: "JohnDoe", password: "password", password_confirmation: "password")
    expect(user).to_not be_valid
  end

  it "is not valid with an invalid email format" do
    user = User.new(name: "JohnDoe", email: "invalid_email", password: "password", password_confirmation: "password")
    expect(user).to_not be_valid
  end

  it "is not valid with a duplicate email" do
    User.create(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password")
    user = User.new(name: "Jane Doe", email: "john@example.com", password: "password", password_confirmation: "password")
    expect(user).to_not be_valid
  end

  it "is not valid with a password shorter than 6 characters" do
    user = User.new(name: "JohnDoe", email: "john@example.com", password: "short", password_confirmation: "short")
    expect(user).to_not be_valid
  end

  it "is not valid when password and password_confirmation don't match" do
    user = User.new(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "different")
    expect(user).to_not be_valid
  end

  it "creates a session token before saving" do
    user = User.create(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password")
    expect(user.session_token).to_not be_nil
  end
  describe "Password reset functionality" do
    let(:user) { User.create(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password") }

    it "generates a reset digest and timestamp" do
      user.create_reset_digest
      expect(user.reset_digest).to_not be_nil
      expect(user.reset_sent_at).to_not be_nil
    end

    it "authenticates a valid reset token" do
      user.create_reset_digest
      expect(user.authenticated?(user.reset_token)).to be true
    end

    it "does not authenticate an invalid reset token" do
      user.create_reset_digest
      expect(user.authenticated?("invalid_token")).to be false
    end

    it "expires the reset token after 20 minutes" do
      user.create_reset_digest
      user.update(reset_sent_at: 21.minutes.ago)
      expect(user.password_reset_expired?).to be true
    end

    it "does not expire the reset token within 20 minutes" do
      user.create_reset_digest
      user.update(reset_sent_at: 19.minutes.ago)
      expect(user.password_reset_expired?).to be false
    end
  end

  describe "Password reset functionality" do
    let(:user) { User.create(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password") }

    it "generates a reset digest and timestamp" do
      user.create_reset_digest
      expect(user.reset_digest).to_not be_nil
      expect(user.reset_sent_at).to_not be_nil
    end

    it "authenticates a valid reset token" do
      user.create_reset_digest
      expect(user.authenticated?(user.reset_token)).to be true
    end

    it "does not authenticate an invalid reset token" do
      user.create_reset_digest
      expect(user.authenticated?("invalid_token")).to be false
    end

    it "expires the reset token after 20 minutes" do
      user.create_reset_digest
      user.update(reset_sent_at: 21.minutes.ago)
      expect(user.password_reset_expired?).to be true
    end

    it "does not expire the reset token within 20 minutes" do
      user.create_reset_digest
      user.update(reset_sent_at: 19.minutes.ago)
      expect(user.password_reset_expired?).to be false
    end
  end
end