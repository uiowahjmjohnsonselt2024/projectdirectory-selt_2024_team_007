class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception
  before_action :set_current_user
  before_action :check_session_timeout

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
    timeout_duration = 1.minutes
    last_seen_at = session[:last_seen_at].present? ? Time.parse(session[:last_seen_at]) : nil
    if last_seen_at && Time.current > last_seen_at + timeout_duration
      reset_session
      redirect_to login_path, alert: "Session has expired. Please log in again."
    else
      session[:last_seen_at] = Time.current.iso8601
    end
  end
end
