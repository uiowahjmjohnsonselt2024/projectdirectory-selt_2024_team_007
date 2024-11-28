class SettingsController < ApplicationController
  def settings
    # Logic for the settings page (if needed)
  end

  def change_email
    @user = @current_user

    # Check if password is provided
    unless params[:current_password].present?
      flash[:danger] = "Current password is required."
      redirect_to settings_path and return
    end

    # Verify the password
    unless @user.authenticate(params[:current_password])
      flash[:danger] = "Incorrect password. Please try again."
      redirect_to settings_path and return
    end

    # Check if new email and confirmation match
    unless params[:new_email] == params[:confirm_email]
      flash[:danger] = "Emails do not match."
      redirect_to settings_path and return
    end

    # Update the email without triggering validations
    if @user.update_columns(email: params[:new_email]) # Skips validations
      flash[:success] = "Your email has been updated successfully."
      redirect_to settings_path
    else
      flash[:danger] = "Failed to update email. Please try again."
      redirect_to settings_path
    end
  end

end
