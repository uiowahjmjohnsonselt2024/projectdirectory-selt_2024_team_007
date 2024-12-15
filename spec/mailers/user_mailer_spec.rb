# *********************************************************************
# This file was crafted using assistance from Generative AI Tools. 
# Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November 
# 4th 2024 to December 15, 2024. The AI Generated code was not 
# sufficient or functional outright nor was it copied at face value. 
# Using our knowledge of software engineering, ruby, rails, web 
# development, and the constraints of our customer, SELT Team 007 
# (Cody Alison, Yusuf Halim, Ziad Hasabrabu, Bradley Johnson, 
# and Sheng Wang) used GAITs responsibly; verifying that each line made
# sense in the context of the app, conformed to the overall design, 
# and was testable. We maintained a strict peer review process before
# any code changes were merged into the development or production 
# branches. All code was tested with BDD and TDD tests as well as 
# empirically tested with local run servers and Heroku deployments to
# ensure compatibility.
# *******************************************************************
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