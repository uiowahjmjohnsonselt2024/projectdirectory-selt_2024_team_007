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
