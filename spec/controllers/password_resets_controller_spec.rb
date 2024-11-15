require 'rails_helper'
require 'factory_bot'


RSpec.describe PasswordResetsController, type: :controller do
  let(:user) { create(:user) }

  describe "GET #edit" do
    it "renders the edit template for a valid token" do
      user.create_reset_digest
      get :edit, params: { id: user.reset_token, email: user.email }
      expect(response).to render_template(:edit)
    end

    it "redirects for an invalid token" do
      get :edit, params: { id: "invalid", email: user.email }
      expect(response).to redirect_to root_url
    end
  end

  describe "PATCH #update" do
    it "updates the password with valid params" do
      user.create_reset_digest
      patch :update, params: { id: user.reset_token, email: user.email, user: { password: "newpassword", password_confirmation: "newpassword" } }
      expect(flash[:success]).to eq("Password has been reset.")
    end

    it "rejects mismatched passwords" do
      user.create_reset_digest
      patch :update, params: { id: user.reset_token, email: user.email, user: { password: "newpassword", password_confirmation: "mismatch" } }
      expect(response).to render_template(:edit)
    end
  end
end
