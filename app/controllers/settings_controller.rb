class SettingsController < ApplicationController
  before_action :set_current_user

  def settings
    # Logic for the settings page (if needed)
  end

  def update_profile_image
    @user = @current_user

    if params[:profile_image].present?
      if @user.update(profile_image: params[:profile_image])
        flash[:success] = "Profile image updated successfully."
      else
        flash[:danger] = "Failed to update profile image. Please try again."
      end
    else
      flash[:danger] = "No image selected."
    end

    redirect_to settings_path
  end

  def update_name
    @user = @current_user

    if params[:name].present? && @user.update(name: params[:name])
      flash[:success] = "Your name has been updated successfully."
    else
      flash[:danger] = @user.errors.full_messages.join(", ").presence || "Failed to update your name."
    end

    redirect_to settings_path
  end

  def change_email

    # Check if password is provided
    unless params[:current_password].present?
      flash[:danger] = "Current password is required."
      redirect_to settings_path and return
    end

    # Verify the password
    unless @current_user.authenticate(params[:current_password])
      flash[:danger] = "Incorrect password. Please try again."
      redirect_to settings_path and return
    end

    # Check if new email and confirmation match
    unless params[:new_email] == params[:confirm_email]
      flash[:danger] = "Emails do not match."
      redirect_to settings_path and return
    end

    # Update the email without triggering validations
    if @current_user.update_columns(email: params[:new_email]) # Skips validations
      flash[:success] = "Your email has been updated successfully."
      redirect_to settings_path
    else
      flash[:danger] = "Failed to update email. Please try again."
      redirect_to settings_path
    end
  end

end
