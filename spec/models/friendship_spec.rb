# *********************************************************************
# This file was crafted using assistance from Generative AI Tools. 
# Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November 
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
