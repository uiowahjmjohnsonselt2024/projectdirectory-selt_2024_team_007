class User < ActiveRecord::Base
  has_secure_password
  before_save { |user| user.email=user.email.downcase }
  before_create :create_session_token
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true


  private
  def create_session_token
    self.session_token = SecureRandom.urlsafe_base64
  end

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth['provider'], uid: auth['uid']) do |user|
      user.name = auth['info']['name']
      user.email = auth['info']['email'] || "#{auth['uid']}@example.com"
      user.password = 'ABcd1234**?'  # Assign a random password(user may not need it)
      # Once user database done: Generate the password randomly and fullfill the password requirement
      user.session_token = SecureRandom.hex(16)  # Generate a session token
    end
  end
end
