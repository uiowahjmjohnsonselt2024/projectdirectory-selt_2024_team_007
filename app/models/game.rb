class Game < ApplicationRecord
  belongs_to :current_turn_user, class_name: 'User', foreign_key: 'current_turn_user_id', optional: true
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id', optional: true

  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users
  has_many :tiles, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :join_code, presence: true, uniqueness: true, format: { with: /\A[A-Z0-9]{6}\z/, message: "must be 6 uppercase alphanumeric characters" }

  # Callbacks
  before_validation :normalize_join_code, on: :create

  private

  def normalize_join_code
    self.join_code = join_code.upcase.strip if join_code.present?
  end
end
