# *********************************************************************
# This file was crafted using assistance from Generative AI Tools.
#   Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November
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
class  ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception
  before_action :check_session_timeout
  before_action :set_current_user

  def index
    redirect_to user_path(@current_user) if @current_user
  end

  def set_current_user
    return redirect_to login_path if session[:session_token].blank?

    @current_user ||= User.find_by_session_token(session[:session_token])
    redirect_to login_path unless @current_user
  end

  def current_user?(id)
    @current_user.id.to_s == id
  end

  def check_session_timeout
    timeout_duration = 20.minute
    last_seen_at = session[:last_seen_at] && Time.parse(session[:last_seen_at])

    Rails.logger.debug("Session last_seen_at: #{last_seen_at}")
    Rails.logger.debug("Current time: #{Time.current}")

    if last_seen_at && Time.current > last_seen_at + timeout_duration
      reset_session
      Rails.logger.debug("Flash set: #{flash[:notice]}")
      flash[:notice] = "Session has expired. Please log in again."
      Rails.logger.debug("Session reset")
      redirect_to login_path
    else
      session[:last_seen_at] = Time.current.iso8601
      Rails.logger.debug("Updated session last_seen_at: #{session[:last_seen_at]}")
    end
  end
end
