require 'rails_helper.rb'

RSpec.describe SessionsController, type: :controller do
  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    let!(:user) { User.create(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password") }

    context "with valid credentials" do
      it "sets the session token" do
        post :create, params: { session: { email: "john@example.com", password: "password" } }
        expect(session[:session_token]).to eq(user.session_token)
      end

      it "redirects to the user's profile" do
        post :create, params: { session: { email: "john@example.com", password: "password" } }
        expect(response).to redirect_to(user_path(user))
      end
    end

    context "with invalid credentials" do
      it "does not set the session token" do
        post :create, params: { session: { email: "john@example.com", password: "wrong_password" } }
        expect(session[:session_token]).to be_nil
      end

      it "renders the 'new' template" do
        post :create, params: { session: { email: "john@example.com", password: "wrong_password" } }
        expect(response).to render_template("new")
      end
    end
  end

  describe "DELETE #destroy" do
    it "clears the session token" do
      delete :destroy
      expect(session[:session_token]).to be_nil
    end

    it "redirects to the root path" do
      delete :destroy
      expect(response).to redirect_to(login_path)
    end
  end
end
