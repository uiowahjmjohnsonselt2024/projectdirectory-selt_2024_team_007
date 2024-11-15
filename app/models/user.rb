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

end
