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
      expect(flash[:notice]).to eq("Password has been reset.")
    end

    it "rejects mismatched passwords" do
      user.create_reset_digest
      patch :update, params: { id: user.reset_token, email: user.email, user: { password: "newpassword", password_confirmation: "mismatch" } }
      expect(response).to render_template(:edit)
    end
  end
  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with a valid email" do
      it "sends a password reset email" do
        post :create, params: { email: user.email }
        expect(ActionMailer::Base.deliveries.size).to eq(1)
        expect(response).to redirect_to login_path
      end
    end

    context "with an invalid email" do
      it "renders the new template with no warning" do
        post :create, params: { email: "nonexistent@example.com" }
        expect(ActionMailer::Base.deliveries.size).to eq(0)
        expect(response).to redirect_to(new_password_reset_path)
      end
    end
  end
end
