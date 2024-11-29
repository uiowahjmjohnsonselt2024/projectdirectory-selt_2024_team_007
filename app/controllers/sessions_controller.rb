class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :set_current_user

  def new
    render "sessions/new"
  end

  def create
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      session[:session_token] = user.session_token
      session[:last_seen_at] = Time.current
      flash[:notice] = "Welcome, #{user.name}!"
      redirect_to landing_path
    else
      flash[:warning] = "Invalid email/password combination"
      redirect_to login_path
    end
  end

  def destroy
    session[:session_token] = nil
    @current_user = nil
    flash[:notice] = "You have logged out"
    redirect_to login_path
  end

  def oauth_create
    auth = request.env['omniauth.auth']
    Rails.logger.debug "OmniAuth Auth Hash: #{auth.inspect}"
    Rails.logger.debug "Session CSRF State: #{session['omniauth.state']}"
    Rails.logger.debug "Request CSRF State: #{params[:state]}"


    user = User.from_omniauth(auth)
    if user
      session[:session_token] = user.session_token
      flash[:notice] = "Welcome, #{user.name}!"
      redirect_to landing_path
    else
      redirect_to login_path
    end
  end

  def auth_failure
    Rails.logger.debug "OmniAuth Authentication Failure: #{params[:message]}"
    flash[:warning] = "Authentication failed: #{params[:message]}"
    redirect_to login_path
  end


end

