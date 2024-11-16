class PasswordResetsController < ApplicationController
  skip_before_action :set_current_user, only: [:edit, :update]
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:update]


  # Display the reset password form
  def edit
    @user.reset_token = params[:id]
  end

  # Update the user's password
  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      redirect_to :edit
    elsif @user.update(user_params)
      flash[:success] = "Password has been reset."
      redirect_to root_url
    else
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
