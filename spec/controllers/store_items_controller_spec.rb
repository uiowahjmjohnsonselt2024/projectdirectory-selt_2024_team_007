require 'rails_helper'

RSpec.describe StoreItemsController, type: :controller do
  let(:user) { create(:user, shards_balance: 100) }

  before do
    session[:session_token] = user.session_token
    allow(IpLocationService).to receive(:get_country_from_ip).and_return('US')
  end

  describe "GET #index" do
    it "assigns all store items to @store_items" do
      get :index
      expect(assigns(:store_items)).to eq(StoreItem.all)
    end

    it "sets a default shard balance if none is set in session" do
      session.delete(:shard_balance)
      get :index
      expect(assigns(:shard_balance)).to eq(100)
    end

    it "uses the existing shard balance from the session" do
      session[:shard_balance] = 150
      get :index
      expect(assigns(:shard_balance)).to eq(150)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "POST #purchase" do
    context "when the user has sufficient shards balance" do
      it "increases the user's shard balance" do
        post :purchase, params: { shard_amount: 50 }
        expect(user.reload.shards_balance).to eq(150) # 100 + 50
      end

      it "sets a success flash message" do
        post :purchase, params: { shard_amount: 50 }
        expect(flash[:success]).to eq("Purchase successful!")
      end

      it "redirects to the store items path" do
        post :purchase, params: { shard_amount: 50 }
        expect(response).to redirect_to(store_items_path)
      end
    end

    context "when the user has insufficient shards balance" do
      before do
        user.update_column(:shards_balance, -10)
      end

      it "does not increase the user's shard balance" do
        post :purchase, params: { shard_amount: 50 }
        expect(user.reload.shards_balance).to eq(-10)
      end

      it "sets a danger flash message" do
        post :purchase, params: { shard_amount: 50 }
        expect(flash[:success]).to eq("Danger!")
      end

      it "redirects to the store items path" do
        post :purchase, params: { shard_amount: 50 }
        expect(response).to redirect_to(store_items_path)
      end
    end
  end

  describe "Private #current_user" do
    context "when session token is present" do
      it "finds the current user by session token" do
        expect(controller.send(:current_user)).to eq(user)
      end
    end

    context "when session token is not present" do
      before do
        session.delete(:session_token)
      end

      it "returns nil" do
        expect(controller.send(:current_user)).to be_nil
      end
    end
  end
end
