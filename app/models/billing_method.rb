class BillingMethod < ApplicationRecord
  belongs_to :user

  validates :card_number, presence: true, uniqueness: { scope: :user_id, message: "Card already exists" },
            length: { is: 16, message: "Card number must be exactly 16 digits" },
            numericality: { only_integer: true, message: "Card number must contain only digits" }

  validates :card_holder_name, presence: true
  validates :expiration_date, presence: true
  validate :expiration_date_cannot_be_in_the_past

  private

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end
end