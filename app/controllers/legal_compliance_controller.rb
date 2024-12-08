class LegalComplianceController < ApplicationController
  skip_before_action :check_session_timeout, only: [:index]

  skip_before_action :set_current_user, only: [:index]
  def index
  end
end
