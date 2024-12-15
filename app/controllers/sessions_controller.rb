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
class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :set_current_user

  def new
    # If the url has play_music, it means the user is comming from firsttime login page
    if params[:play_music]
      session[:firsttime_shown] = true
    else
      # if the user is the first time visiting, with no [play music], redirect to login-firsttime
      unless session[:firsttime_shown]
        redirect_to login_firsttime_path and return
      end
    end
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

    user = User.from_omniauth(auth)
    if user
      session[:session_token] = user.session_token
      session[:oauth_login] = true
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

  def login_firsttime
    #
  end
end

