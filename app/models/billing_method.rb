# *********************************************************************
# This file was crafted using assistance from Generative AI Tools.
#   Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November
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
class BillingMethod < ApplicationRecord
  belongs_to :user

  validates :card_number, presence: true, uniqueness: { scope: :user_id, message: "Card already exists" },
            length: { is: 16, message: "Card number must be exactly 16 digits" },
            numericality: { only_integer: true, message: "Card number must contain only digits" }

  validates :card_holder_name, presence: true
  validates :expiration_date, presence: true
  validate :expiration_date_cannot_be_in_the_past
  validates :cvv, presence: true,
            length: { in: 3..4, message: "CVV must be 3 or 4 digits" },
            numericality: { only_integer: true, message: "CVV must contain only digits" }

  private

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end
end