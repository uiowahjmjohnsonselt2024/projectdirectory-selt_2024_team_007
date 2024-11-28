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
    let(:user) { create(:user) }

    context "when the password reset has expired" do
      before do
        user.create_reset_digest
        user.update(reset_sent_at: 3.hours.ago) # Simulate expiration
      end

      it "redirects to the root URL with a danger flash message" do
        patch :update, params: { id: user.reset_token, email: user.email, user: { password: "newpassword", password_confirmation: "newpassword" } }
        expect(flash[:danger]).to eq("Password reset has expired.")
        expect(response).to redirect_to(root_url)
      end
    end

    context "when the reset digest is present" do
      before do
        user.create_reset_digest
      end

      it "allows password update with valid params" do
        patch :update, params: { id: user.reset_token, email: user.email, user: { password: "newpassword", password_confirmation: "newpassword" } }
        expect(flash[:notice]).to eq("Password has been reset.")
        expect(user.reload.authenticate("newpassword")).to be_truthy
      end

      it "renders the edit template with mismatched passwords" do
        patch :update, params: { id: user.reset_token, email: user.email, user: { password: "newpassword", password_confirmation: "mismatch" } }
        expect(response).to render_template(:edit)
      end
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

    context "with a missing or empty email" do
      it "redirects to login with a danger flash message" do
        post :create, params: { email: "" }
        expect(flash[:danger]).to eq("There was an error")
        expect(response).to redirect_to login_path
      end

      it "redirects to login with a danger flash message if email is nil" do
        post :create, params: { email: nil }
        expect(flash[:danger]).to eq("There was an error")
        expect(response).to redirect_to login_path
      end
    end
  end
end
