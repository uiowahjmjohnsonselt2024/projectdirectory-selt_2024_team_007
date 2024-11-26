class PasswordResetsController < ApplicationController
  skip_before_action :set_current_user, only: [:edit, :update, :new, :create]
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:update]

  # Display the form to request a password reset
  def new
  end

  # Handle the form submission and send the email
  def create
    if params[:email].nil? || params[:email].empty?
      flash[:danger] = "There was an error"
      redirect_to login_path
    end
    @user = User.find_by(email: params[:email].downcase)

    if @user
      @user.create_reset_digest
      begin
        UserMailer.password_reset(@user).deliver_now
        flash[:success] = "Password reset email has been sent."
      rescue => e
        flash[:alert] = "We couldn't send the password reset email. Please try again later."
      end
      redirect_to login_path
    else
      flash.now[:notice] = "Email address not found."
      redirect_to new_password_reset_path
    end
  end

  # Display the reset password form
  def edit
    @user.reset_token = params[:id]
  end

  # Update the user's password
  def update
    if @user.reset_digest.nil?
      flash[:danger] = "Invalid or expired token."
      redirect_to root_url
      return
    end

    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      redirect_to :edit
    elsif @user.update(user_params)
      # Invalidate the token by setting reset_digest to nil
      @user.update(reset_digest: nil, reset_sent_at: nil)

      flash[:notice] = "Password has been reset."
      redirect_to root_url
    else
      flash.now[:danger] = @user.errors.full_messages.join(', ')
      @user.reset_token = params[:id]
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    unless @user&.authenticated?(params[:id])
      flash[:danger] = "Invalid User"
      redirect_to root_url
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to root_url
    end
  end
end
