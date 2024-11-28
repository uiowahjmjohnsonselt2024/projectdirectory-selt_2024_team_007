class User < ActiveRecord::Base
  has_secure_password
  before_save { |user| user.email=user.email.downcase }
  before_create :create_session_token

  VALID_NAME_REGEX = /\A[^\s]+\z/
  validates :name, presence: true, length: { in: 3..50 }, format: { with: VALID_NAME_REGEX }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  validates :shards_balance, numericality: { greater_than_or_equal_to: 0 }

  attr_accessor :reset_token

  # Generates a password reset digest and timestamp
  def create_reset_digest
    self.reset_token = SecureRandom.urlsafe_base64
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # Checks if the reset token matches the digest
  def authenticated?(token)
    return false if reset_digest.nil?
    BCrypt::Password.new(reset_digest).is_password?(token)
  end

  # Checks if the password reset token has expired (20 minutes)
  def password_reset_expired?
    reset_sent_at < 20.minutes.ago
  end

  # Hash a string using BCrypt
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end


  private
  def create_session_token
    self.session_token = SecureRandom.urlsafe_base64
  end

  def self.from_omniauth(auth)
    user = find_by(uid: auth['uid']) || find_by(email: auth['info']['email'])
    return user if user

    begin
      password = SecureRandom.base64(12)
      user = self.create!(
        uid: auth['uid'],
        name: auth['info']['name'] || "Unknown User",
        email: auth['info']['email'] || "#{auth['uid']}@google.com",
        password: password,
        password_confirmation: password,
        session_token: SecureRandom.hex(16)
      )
      Rails.logger.debug "User created successfully: #{user.inspect}"
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.debug "User creation failed: #{e.message}"
      return nil
    end

    user
  end

  has_many :game_users, dependent: :destroy
  has_many :games, through: :game_users
  has_many :owned_games, class_name: 'Game', foreign_key: 'owner_id', dependent: :nullify
  has_many :current_turn_games, class_name: 'Game', foreign_key: 'current_turn_user_id', dependent: :nullify
end
