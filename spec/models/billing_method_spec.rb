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
