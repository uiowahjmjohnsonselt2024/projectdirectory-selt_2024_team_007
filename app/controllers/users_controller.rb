class UsersController < ApplicationController
  before_action :set_current_user, only: [ "show", "destroy", "edit"]

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def show
    @user = @current_user
    if !current_user?(params[:id])
      flash[:warning] = "Can only show profile of logged-in user"
    end
  end

  def edit
    @user = @current_user
  end
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "Sign up successful! Welcome!"
      redirect_to login_path
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      Rails.logger.error(@user.errors.full_messages) # Log errors
      render :new
    end
  end

  def destroy
    @current_user.destroy # Assuming you want to delete the current user's account
    flash[:notice] = "Account deleted successfully."
    redirect_to root_path # Redirect after deletion
  end

  protected

  def current_user?(id)
    @current_user.id.to_s == id
  end
end
