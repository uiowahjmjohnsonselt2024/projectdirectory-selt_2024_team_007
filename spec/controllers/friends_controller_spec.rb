require 'rails_helper'

RSpec.describe FriendsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:friend) { create(:user, email: "friend@example.com") }
  let!(:pending_friend) { create(:user, email: "pending@example.com") }
  let!(:friendship) { create(:friendship, user: user, friend: friend, status: "accepted") }
  let!(:pending_friendship) { create(:friendship, user: user, friend: pending_friend, status: "pending") }

  before do
    allow(controller).to receive(:set_current_user).and_return(user)
    controller.instance_variable_set(:@current_user, user)
  end

  describe "GET #index" do
    it "assigns the user's friends, pending friend requests, and sent friend requests" do
      get :index
      expect(assigns(:friends)).to eq([friend])
      expect(assigns(:pending_friend_requests)).to eq([])
      expect(assigns(:sent_friend_requests)).to eq([pending_friend])
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "when the friend exists and is valid" do
      it "creates a friend request" do
        new_friend = create(:user, name: "newfriend")
        expect {
          post :create, params: { friend_name: new_friend.name }
        }.to change(Friendship, :count).by(1)

        expect(flash[:notice]).to eq("Friend request sent to #{new_friend.name}!")
        expect(response).to redirect_to(friends_path)
      end
    end

    context "when the friend does not exist" do
      it "sets a flash alert and redirects" do
        post :create, params: { friend_name: "nonexistentUser" }
        expect(flash[:alert]).to eq("No user found with the name nonexistentUser.")
        expect(response).to redirect_to(friends_path)
      end
    end

    context "when trying to friend oneself" do
      it "sets a flash alert and redirects" do
        post :create, params: { friend_name: user.name }
        expect(flash[:alert]).to eq("You cannot send a friend request to yourself.")
        expect(response).to redirect_to(friends_path)
      end
    end
  end

  describe "POST #accept" do
    it "accepts a friend request" do
      pending_request = create(:friendship, user: pending_friend, friend: user, status: "pending")
      post :accept, params: { id: pending_request.user.id }

      pending_request.reload
      expect(pending_request.status).to eq("accepted")
      expect(flash[:success]).to eq("Friend request accepted.")
      expect(response).to redirect_to(friends_path)
    end
  end

  describe "DELETE #reject" do
    it "rejects a friend request" do
      pending_request = create(:friendship, user: pending_friend, friend: user, status: "pending")
      delete :reject, params: { id: pending_request.user.id }

      expect(Friendship.exists?(id: pending_request.id)).to be_falsey
      expect(flash[:notice]).to eq("Friend request rejected.")
      expect(response).to redirect_to(friends_path)
    end
  end

  describe "DELETE #cancel" do
    it "cancels a sent friend request" do
      delete :cancel, params: { id: pending_friend.id }
      expect(Friendship.exists?(id: pending_friendship.id)).to be_falsey
      expect(flash[:notice]).to eq("Friend request canceled.")
      expect(response).to redirect_to(friends_path)
    end
  end
end
