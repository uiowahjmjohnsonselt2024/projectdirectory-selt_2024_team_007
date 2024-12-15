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

RSpec.describe BillingMethod, type: :model do
  let(:user) { create(:user) }

  context "validations" do
    it "is valid with valid attributes" do
      billing_method = BillingMethod.new(
        user: user,
        card_number: "1234567812345678",
        card_holder_name: "John Doe",
        expiration_date: Date.today + 1.year,
        cvv: "123",
      )
      expect(billing_method).to be_valid
    end

    it "is invalid without a card number" do
      billing_method = BillingMethod.new(
        user: user,
        card_holder_name: "John Doe",
        expiration_date: Date.today + 1.year,
        cvv: "123",
      )
      expect(billing_method).to_not be_valid
      expect(billing_method.errors[:card_number]).to include("can't be blank")
    end

    it "is invalid with a duplicate card number for the same user" do
      # Create the initial billing method directly
      BillingMethod.create!(
        user: user,
        card_number: "1234567812345678",
        card_holder_name: "John Doe",
        expiration_date: Date.today + 1.year,
        cvv: "145"
      )

      # Attempt to create a duplicate billing method
      duplicate = BillingMethod.new(
        user: user,
        card_number: "1234567812345678", # Same card number
        card_holder_name: "John Doe",
        expiration_date: Date.today + 1.year,
        cvv: "145"
      )

      # Validate that the duplicate is invalid
      expect(duplicate).to_not be_valid
      expect(duplicate.errors[:card_number]).to include("Card already exists")
    end

    it "is invalid with a card number shorter than 16 digits" do
      billing_method = BillingMethod.new(
        user: user,
        card_number: "123",
        card_holder_name: "John Doe",
        expiration_date: Date.today + 1.year,
        cvv: "145"
      )
      expect(billing_method).to_not be_valid
      expect(billing_method.errors[:card_number]).to include("Card number must be exactly 16 digits")
    end

    it "is invalid with an expiration date in the past" do
      billing_method = BillingMethod.new(
        user: user,
        card_number: "1234567812345678",
        card_holder_name: "John Doe",
        expiration_date: Date.today - 1.day,
        cvv: "145"
      )
      expect(billing_method).to_not be_valid
      expect(billing_method.errors[:expiration_date]).to include("can't be in the past")
    end
  end
end
