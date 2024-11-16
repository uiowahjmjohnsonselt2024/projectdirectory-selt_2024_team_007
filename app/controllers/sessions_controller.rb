class SessionsController < ApplicationController
  skip_before_action :set_current_user

  def new
    puts "Rendering new session form"  # Debugging output
    render "sessions/new" # explicitly render the template
  end

  def create
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      session[:session_token] = user.session_token
      session[:last_seen_at] = Time.current
      redirect_to user_path(user)  # Redirect to user"s profile or another page after successful login
    else
      flash.now[:warning] = "Invalid email/password combination"
      render "new"
    end
  end

  def destroy
    session[:session_token] = nil
    @current_user = nil
    flash[:notice] = "You have logged out"
    redirect_to login_path  # Redirect to login page after logout
  end

  def oauth_create
    auth = request.env['omniauth.auth']  # Catch auth info
    Rails.logger.debug "OmniAuth Auth Hash: #{auth.inspect}"

    # Call create from model
    user = User.from_omniauth(auth)
    if user
      session[:session_token] = user.session_token
      flash[:notice] = "Welcome, #{user.name}!"
      redirect_to user_path(user)
    else
      Rails.logger.debug "b!"
      redirect_to login_path
    end
  end
end
