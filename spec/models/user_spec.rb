require 'rails_helper.rb'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = User.new(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password")
    expect(user).to be_valid
  end

  it "is not valid without a name" do
    user = User.new(email: "john@example.com", password: "password", password_confirmation: "password")
    expect(user).to_not be_valid
  end

  it "is not valid without an email" do
    user = User.new(name: "JohnDoe", password: "password", password_confirmation: "password")
    expect(user).to_not be_valid
  end

  it "is not valid with an invalid email format" do
    user = User.new(name: "JohnDoe", email: "invalid_email", password: "password", password_confirmation: "password")
    expect(user).to_not be_valid
  end

  it "is not valid with a duplicate email" do
    User.create(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password")
    user = User.new(name: "Jane Doe", email: "john@example.com", password: "password", password_confirmation: "password")
    expect(user).to_not be_valid
  end

  it "is not valid with a password shorter than 6 characters" do
    user = User.new(name: "JohnDoe", email: "john@example.com", password: "short", password_confirmation: "short")
    expect(user).to_not be_valid
  end

  it "is not valid when password and password_confirmation don't match" do
    user = User.new(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "different")
    expect(user).to_not be_valid
  end

  it "creates a session token before saving" do
    user = User.create(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password")
    expect(user.session_token).to_not be_nil
  end

  describe "Item management" do
    let(:user) { User.create(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password") }
    let(:store_item) { StoreItem.new(id: 1, name: "Teleport", description: "Instantly teleport to any location.", shards_cost: 2) }

    it "initializes with 0 count for all items" do
      expect(user.item_count(store_item.id)).to eq(0)
    end

    it "increments item count when purchasing an item" do
      user.increment_item_count(store_item.id)
      expect(user.item_count(store_item.id)).to eq(1)
    end

    it "does not increment item count for invalid item IDs" do
      invalid_item_id = 999
      expect { user.increment_item_count(invalid_item_id) }.not_to change { user.item_count(invalid_item_id) }
    end
  end

  describe "Password reset functionality" do
    let(:user) { User.create(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password") }

    it "generates a reset digest and timestamp" do
      user.create_reset_digest
      expect(user.reset_digest).to_not be_nil
      expect(user.reset_sent_at).to_not be_nil
    end

    it "authenticates a valid reset token" do
      user.create_reset_digest
      expect(user.authenticated?(user.reset_token)).to be true
    end

    it "does not authenticate an invalid reset token" do
      user.create_reset_digest
      expect(user.authenticated?("invalid_token")).to be false
    end

    it "expires the reset token after 20 minutes" do
      user.create_reset_digest
      user.update(reset_sent_at: 21.minutes.ago)
      expect(user.password_reset_expired?).to be true
    end

    it "does not expire the reset token within 20 minutes" do
      user.create_reset_digest
      user.update(reset_sent_at: 19.minutes.ago)
      expect(user.password_reset_expired?).to be false
    end
  end

  describe "Password reset functionality" do
    let(:user) { User.create(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password") }

    it "generates a reset digest and timestamp" do
      user.create_reset_digest
      expect(user.reset_digest).to_not be_nil
      expect(user.reset_sent_at).to_not be_nil
    end

    it "authenticates a valid reset token" do
      user.create_reset_digest
      expect(user.authenticated?(user.reset_token)).to be true
    end

    it "does not authenticate an invalid reset token" do
      user.create_reset_digest
      expect(user.authenticated?("invalid_token")).to be false
    end

    it "expires the reset token after 20 minutes" do
      user.create_reset_digest
      user.update(reset_sent_at: 21.minutes.ago)
      expect(user.password_reset_expired?).to be true
    end

    it "does not expire the reset token within 20 minutes" do
      user.create_reset_digest
      user.update(reset_sent_at: 19.minutes.ago)
      expect(user.password_reset_expired?).to be false
    end
  end



  describe '.from_omniauth' do
    let(:auth) { OmniAuth::AuthHash.new(provider: 'google_oauth2', uid: '12345', info: { name: 'Test User', email: 'test@example.com' }) }

    context 'when user exists by uid' do
      let!(:existing_user) do
        User.create!(
          uid: '12345',
          name: 'Existing User',
          email: 'existing@example.com',
          password: 'password',
          password_confirmation: 'password',
          session_token: 'token123'
        )
      end

      it 'returns the existing user' do
        user = User.from_omniauth(auth)
        expect(user).to eq(existing_user)
      end
    end

    context 'when user exists by email' do
      let!(:existing_user) do
        User.create!(
          uid: '67890',
          name: 'Existing Email User',
          email: 'test@example.com',
          password: 'password',
          password_confirmation: 'password',
          session_token: 'token456'
        )
      end

      it 'returns the existing user' do
        user = User.from_omniauth(auth)
        expect(user).to eq(existing_user)
      end
    end

    context 'when user does not exist and is successfully created' do
      it 'creates and returns a new user' do
        expect {
          @new_user = User.from_omniauth(auth)
        }.to change(User, :count).by(1)

        expect(@new_user.uid).to eq('12345')
        expect(@new_user.email).to eq('test@example.com')
        expect(@new_user.name).to match(/^TestUser[A-Z]{6}$/)
        expect(@new_user.session_token).to be_present
      end
    end

    context 'when user creation fails' do
      let(:invalid_auth) { OmniAuth::AuthHash.new(provider: 'google_oauth2', uid: '12345', info: { name: 'Test User', email: 'test@example.com' }) }

      it 'returns nil' do
        # 模拟 User.create! 抛出 ActiveRecord::RecordInvalid 异常
        allow(User).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(User.new))

        user = User.from_omniauth(invalid_auth)
        expect(user).to be_nil
      end
    end

    context "when user's name is nil or empty" do
      let(:auth_without_name) { OmniAuth::AuthHash.new(provider: 'google_oauth2', uid: '54321', info: { name: nil, email: 'noname@example.com' }) }

      it 'uses the default name "UnknownUser" and adds a random suffix' do
        user = User.from_omniauth(auth_without_name)
        expect(user.name).to match(/^UnknownUser[A-Z]{6}$/)
      end
    end

    context "when user's email is nil" do
      let(:auth_without_email) { OmniAuth::AuthHash.new(provider: 'google_oauth2', uid: '99999', info: { name: 'NoEmail User', email: nil }) }

      it 'uses uid to generate the default email' do
        expect {
          user = User.from_omniauth(auth_without_email)
          expect(user.email).to eq('99999@google.com')
        }.to change(User, :count).by(1)
      end
    end
  end
end