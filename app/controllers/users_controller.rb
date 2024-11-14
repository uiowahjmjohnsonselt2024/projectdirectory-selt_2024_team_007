class UsersController < ApplicationController
  before_action :set_current_user, only: [ "show", "edit", "update", "destroy" ]

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def show
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
      render "new"
    end
  end

  private

  def current_user?(id)
    @current_user.id.to_s == id.to_s
  end
end
