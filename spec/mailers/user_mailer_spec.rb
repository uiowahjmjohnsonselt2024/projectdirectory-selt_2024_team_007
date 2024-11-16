require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe "password_reset" do
    let(:user) { create(:user, reset_token: SecureRandom.urlsafe_base64) }

    it "sends a password reset email" do
      email = UserMailer.password_reset(user).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(email.to).to eq([user.email])
      expect(email.subject).to eq("Password Reset")
      expect(email.body.encoded).to include(edit_password_reset_url(user.reset_token, email: user.email))
    end
  end
end