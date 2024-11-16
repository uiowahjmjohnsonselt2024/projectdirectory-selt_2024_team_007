class ApplicationController < ActionController::Base
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
