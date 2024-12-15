#*********************************************************************
# This file was crafted using assistance from Generative AI Tools.
# Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November
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
class UsersController < ApplicationController
  before_action :set_current_user, only: [ "show", "destroy", "edit"]

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :profile_image)
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
