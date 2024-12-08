require 'rails_helper'

RSpec.describe StoreItemsController, type: :controller do
  let(:user) { create(:user, shards_balance: 100) }
  let!(:store_item) { create(:store_item, id: 4, name: "Exclusive Item", shards_cost: 30) }

  before do
    session[:session_token] = user.session_token
    allow(IpLocationService).to receive(:get_country_from_ip).and_return('US')
    # Stub external exchange rate API call
    stub_request(:get, /data.fixer.io/).to_return(
      status: 200,
      body: { rates: { USD: 1.0, JPY: 130.0 } }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
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

    it "uses an existing shard balance from the session" do
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
    context "when purchasing a shard package" do
      it "increases the user's shard balance" do
        post :purchase, params: { shard_amount: 50 }
        expect(user.reload.shards_balance).to eq(150)
        expect(flash[:success]).to eq("Purchase successful!")
      end
    end

    context "when purchasing a store item with exact shard amount" do
      before { user.update_column(:shards_balance, 30) }

      it "deducts the exact shard amount and adds the item" do
        post :purchase, params: { shard_amount: 30, item_id: store_item.id }
        user.reload
        expect(user.shards_balance).to eq(0)
        expect(user.owns_item?(store_item.id)).to be true
        expect(flash[:success]).to include("Successfully purchased #{store_item.name}")
      end
    end

    context "when the user has insufficient shards" do
      before { user.update_column(:shards_balance, 10) }

      it "does not deduct shards and sets a danger flash message" do
        post :purchase, params: { shard_amount: 30, item_id: store_item.id }
        expect(user.reload.shards_balance).to eq(10)
        expect(flash[:danger]).to eq("Insufficient Shard Balance. You need 20 more shards.")
      end
    end

    context "when the user already owns the item" do
      before do
        user.add_store_item(store_item.id)
        user.update_column(:shards_balance, 100)
      end

      it "does not deduct shards and sets a warning flash message" do
        post :purchase, params: { shard_amount: 30, item_id: store_item.id }
        expect(user.reload.shards_balance).to eq(100)
        expect(flash[:warning]).to eq("You already own #{store_item.name}!")
      end
    end

    context "when shard_amount is invalid" do
      it "sets a danger flash message for invalid shard amount" do
        post :purchase, params: { shard_amount: 999 }
        expect(flash[:danger]).to eq("Invalid shard amount! Please select a valid purchase option.")
      end
    end
  end

  describe "Private #current_user" do
    context "when session token is present" do
      it "returns the user" do
        expect(controller.send(:current_user)).to eq(user)
      end
    end

    context "when session token is not present" do
      before { session.delete(:session_token) }

      it "returns nil" do
        expect(controller.send(:current_user)).to be_nil
      end
    end
  end

  describe "Private #set_currency" do
    it "sets the currency based on user IP" do
      allow(IpLocationService).to receive(:get_country_from_ip).and_return('JP')
      controller.send(:set_currency)
      expect(assigns(:currency)).to eq('JPY')
    end

    it "defaults to USD if country code is unknown" do
      allow(IpLocationService).to receive(:get_country_from_ip).and_return(nil)
      controller.send(:set_currency)
      expect(assigns(:currency)).to eq('USD')
    end
  end
end