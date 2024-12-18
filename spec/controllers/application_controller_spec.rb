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

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'OK'
    end

    def test_set_current_user
      set_current_user
      render plain: 'OK'
    end

    def test_check_session_timeout
      check_session_timeout
      render plain: 'OK'
    end
  end

  before do
    routes.draw do
      get "test_set_current_user" => "anonymous#test_set_current_user"
      get "test_check_session_timeout" => "anonymous#test_check_session_timeout"
      get "index" => "anonymous#index"
    end
  end

  let(:user) { User.create!(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password") }

  describe "#set_current_user" do
    context "when session token is blank" do
      it "redirects to login path" do
        session[:session_token] = nil
        get :test_set_current_user
        expect(response).to redirect_to(login_path)
      end
    end

    context "when session token is present" do
      it "sets @current_user" do
        session[:session_token] = user.session_token
        allow(User).to receive(:find_by_session_token).and_return(user)
        get :test_set_current_user
        expect(assigns(:current_user)).to eq(user)
      end

      it "redirects to login path if user not found" do
        session[:session_token] = "invalid_token"
        allow(User).to receive(:find_by_session_token).and_return(nil)
        get :test_set_current_user
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "#current_user?" do
    before do
      controller.instance_variable_set(:@current_user, user)
    end

    it "returns true when id matches current user's id" do
      expect(controller.send(:current_user?, user.id.to_s)).to be true
    end

    it "returns false when id does not match current user's id" do
      expect(controller.send(:current_user?, (user.id + 1).to_s)).to be false
    end
  end

  describe "#check_session_timeout" do
    context "when session has expired" do
      before do
        session[:session_token] = user.session_token
        session[:last_seen_at] = 22.minutes.ago.iso8601
        get :index
      end

      it "resets the session and redirects to login path" do
        expect(session[:session_token]).to be_nil
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to eq("Session has expired. Please log in again.")
      end
    end

    context "when session has not expired" do
      before do
        session[:session_token] = user.session_token
        session[:last_seen_at] = Time.current.iso8601
        get :index
      end

      it "does not reset the session or redirect" do
        expect(response).not_to redirect_to(login_path)
        expect(flash[:notice]).to be_nil
      end
    end
  end
end
