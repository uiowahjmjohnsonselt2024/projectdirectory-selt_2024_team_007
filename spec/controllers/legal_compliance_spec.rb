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
# spec/requests/legal_compliance_spec.rb

require 'rails_helper'

RSpec.describe "LegalCompliance", type: :request do
  describe "GET /legal_compliance" do
    it "successfully response" do
      get legal_compliance_index_path
      expect(response).to have_http_status(:ok)
    end

    it "correctly render index model" do
      get legal_compliance_index_path
      expect(response).to render_template(:index)
    end

    it "skips check_session_timeout and set_current_user before_action" do
      get legal_compliance_index_path
      expect(assigns(:current_user)).to be_nil
    end
  end
end
