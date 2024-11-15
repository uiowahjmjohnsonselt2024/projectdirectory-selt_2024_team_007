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
      redirect_to user_path(user)  # Redirect to user"s profile or another page after successful login
    else
      flash.now[:warning] = "Invalid email/password combination"
      puts "Failed login attempt for email: #{params[:session][:email]}"  # Debugging output
      render "new"
    end
  end

  def destroy
    session[:session_token] = nil
    @current_user = nil
    flash[:notice] = "You have logged out"
    redirect_to login_path  # Redirect to login page after logout
  end
end
