require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  let(:user) { create(:user, email: "user@example.com", reset_digest: nil, reset_sent_at: nil) }

  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with a valid email" do
      it "sends a password reset email" do
        allow(UserMailer).to receive_message_chain(:password_reset, :deliver_now)
        post :create, params: { email: user.email }
        expect(user.reload.reset_digest).not_to be_nil
        expect(flash[:success]).to eq("Password reset email has been sent.")
        expect(response).to redirect_to(login_path)
      end

      it "handles email delivery failure gracefully" do
        allow(UserMailer).to receive(:password_reset).and_raise("Email delivery failed")
        post :create, params: { email: user.email }
        expect(flash[:alert]).to eq("We couldn't send the password reset email. Please try again later.")
        expect(response).to redirect_to(login_path)
      end
    end

    context "with an invalid email" do
      it "does not send an email and redirects to the password reset page" do
        post :create, params: { email: "invalid@example.com" }
        expect(flash[:notice]).to eq("Email address not found.")
        expect(response).to redirect_to(new_password_reset_path)
      end
    end

    context "with a missing email" do
      it "displays an error and redirects to the login page" do
        post :create, params: { email: "" }
        expect(flash[:danger]).to eq("There was an error")
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET #edit" do
    before { user.create_reset_digest }

    it "assigns the user and renders the edit template if token is valid" do
      get :edit, params: { id: user.reset_token, email: user.email }
      expect(assigns(:user)).to eq(user)
      expect(response).to render_template(:edit)
    end

    it "redirects to root with an error if the token is invalid" do
      get :edit, params: { id: "invalid_token", email: user.email }
      expect(flash[:danger]).to eq("Invalid User")
      expect(response).to redirect_to(root_url)
    end
  end

  describe "PATCH #update" do
    before { user.create_reset_digest }

    context "with a valid token and valid password" do
      it "resets the password and redirects to the root path" do
        patch :update, params: { id: user.reset_token, email: user.email, user: { password: "newpassword", password_confirmation: "newpassword" } }
        expect(user.reload.authenticate("newpassword")).to eq(user)
        expect(flash[:notice]).to eq("Password has been reset.")
        expect(response).to redirect_to(root_url)
        expect(user.reload.reset_digest).to be_nil
      end
    end

    context "with a valid token but an empty password" do
      it "displays an error and renders the edit template" do
        patch :update, params: { id: user.reset_token, email: user.email, user: { password: "", password_confirmation: "" } }
        expect(assigns(:user).errors[:password]).to include("can't be empty")
        expect(flash.now[:danger]).to include("Password can't be empty")
        expect(response).to render_template(:edit)
      end
    end

    context "with an invalid token" do
      it "redirects to root with an error" do
        patch :update, params: { id: "invalid_token", email: user.email, user: { password: "newpassword", password_confirmation: "newpassword" } }
        expect(flash[:danger]).to eq("Invalid User")
        expect(response).to redirect_to(root_url)
      end
    end

    context "when the token has expired" do
      it "displays an error and redirects to the root path" do
        user.update(reset_sent_at: 3.hours.ago) # Simulate token expiration
        patch :update, params: { id: user.reset_token, email: user.email, user: { password: "newpassword", password_confirmation: "newpassword" } }
        expect(flash[:danger]).to eq("Password reset has expired.")
        expect(response).to redirect_to(root_url)
      end
    end

  end
end
