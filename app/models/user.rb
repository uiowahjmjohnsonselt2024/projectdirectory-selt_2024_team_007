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
class User < ActiveRecord::Base
  has_secure_password
  has_one_attached :profile_image
  before_save { |user| user.email=user.email.downcase }
  before_create :create_session_token

  validates :teleport, :health_potion, :resurrection_token,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  VALID_NAME_REGEX = /\A[^\s]+(\s[^\s]+)*\z/
  validates :name, presence: true, length: { in: 3..50 }, format: { with: VALID_NAME_REGEX }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  validates :shards_balance, numericality: { greater_than_or_equal_to: 0 }

  # Friendships where the user is the initiator
  has_many :friendships, dependent: :destroy
  has_many :friends, -> { where(friendships: { status: 'accepted' }) }, through: :friendships, source: :friend

  # Friendships where the user is the recipient
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy
  has_many :inverse_friends, -> { where(friendships: { status: 'accepted' }) }, through: :inverse_friendships, source: :user

  # Pending friend requests sent by this user
  has_many :pending_friendships, -> { where(status: 'pending') }, class_name: 'Friendship'
  has_many :pending_friends, through: :pending_friendships, source: :friend

  # Pending friend requests received by this user
  has_many :received_friend_requests, -> { where(status: 'pending') }, class_name: 'Friendship', foreign_key: 'friend_id'
  has_many :requesting_friends, through: :received_friend_requests, source: :user
  has_many :billing_methods, dependent: :destroy
  has_many :orders, dependent: :destroy

  has_and_belongs_to_many :store_items, join_table: :user_store_items

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

  def add_store_item(item_id)
    case item_id
    when 1
      increment!(:teleport)
    when 2
      increment!(:health_potion)
    when 3
      increment!(:resurrection_token)
    else
      unless UserStoreItem.exists?(user_id: self.id, store_item_id: item_id)
        UserStoreItem.create!(user_id: self.id, store_item_id: item_id)
      end
    end
  end

  def owns_item?(item_id)
    store_items.exists?(id: item_id) # Assuming a relationship `store_items` exists
  end

  def item_count(item_id)
    case item_id
    when 1
      teleport
    when 2
      health_potion
    when 3
      resurrection_token
    else
      0
    end
  end


  private

  def password_required?
    password.present? || password_confirmation.present?
  end
  def create_session_token
    self.session_token = SecureRandom.urlsafe_base64
  end

  def self.from_omniauth(auth)
    user = find_by(uid: auth['uid']) || find_by(email: auth['info']['email'])
    return user if user

    begin
      password = SecureRandom.base64(12)
      name = auth['info']['name']&.gsub(/\s+/, '') || "UnknownUser"
      random_suffix = Array.new(6) { ('A'..'Z').to_a.sample }.join
      user = self.create!(
        uid: auth['uid'],
        name: "#{name}#{random_suffix}",
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
