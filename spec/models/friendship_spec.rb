require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let!(:user) { create(:user) }
  let!(:friend) { create(:user) }

  context "validations" do
    it "validates uniqueness of friendship" do
      create(:friendship, user: user, friend: friend)
      duplicate_friendship = Friendship.new(user: user, friend: friend)
      expect(duplicate_friendship.valid?).to be_falsey
      expect(duplicate_friendship.errors[:user_id]).to include("Friendship already exists")
    end

    it "allows creating a reverse friendship" do
      create(:friendship, user: user, friend: friend)
      reverse_friendship = Friendship.new(user: friend, friend: user, status: "accepted")
      expect(reverse_friendship).to be_valid
    end
  end

  context "scopes" do
    it "returns accepted friendships" do
      create(:friendship, user: user, friend: friend, status: "accepted")
      expect(Friendship.accepted.count).to eq(1)
    end

    it "returns pending friendships" do
      create(:friendship, user: user, friend: friend, status: "pending")
      expect(Friendship.pending.count).to eq(1)
    end
  end
end
