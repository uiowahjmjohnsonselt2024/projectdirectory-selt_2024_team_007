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
require 'rails_helper.rb'

RSpec.describe SessionsController, type: :controller do
  describe "GET #new" do
    it "returns a success response when firsttime_shown is set" do
      session[:firsttime_shown] = true
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    let!(:user) { User.create(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password") }

    context "with valid credentials" do
      it "sets the session token" do
        post :create, params: { session: { email: "john@example.com", password: "password" } }
        expect(session[:session_token]).to eq(user.session_token)
      end

      it "redirects to the user's landing page" do
        post :create, params: { session: { email: "john@example.com", password: "password" } }
        expect(response).to redirect_to(landing_path)
      end
    end

    context "with invalid credentials" do
      it "does not set the session token" do
        post :create, params: { session: { email: "john@example.com", password: "wrong_password" } }
        expect(session[:session_token]).to be_nil
      end

      it "renders the 'new' template" do
        post :create, params: { session: { email: "john@example.com", password: "wrong_password" } }
        expect(response).to redirect_to(login_path)
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

  describe "GET #oauth_create" do
    context "User successfully pass the auth" do
      before do
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
      end

      it "find the user, get the session，redirect to landing_path" do

        user = double("User", session_token: "mock_session_token", name: "Test User")
        allow(User).to receive(:from_omniauth).with(request.env["omniauth.auth"]).and_return(user)

        get :oauth_create, params: { provider: 'github' }

        expect(session[:session_token]).to eq("mock_session_token")
        expect(flash[:notice]).to eq("Welcome, Test User!")
        expect(response).to redirect_to(landing_path)
      end
    end

    context "The user does not exist" do
      before do
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
      end

      it "redirect to login_path" do
        allow(User).to receive(:from_omniauth).with(request.env["omniauth.auth"]).and_return(nil)

        get :oauth_create, params: { provider: 'github' }

        expect(session[:session_token]).to be_nil
        expect(flash[:notice]).to be_nil
        expect(response).to redirect_to(login_path)
      end
    end
  end

end
