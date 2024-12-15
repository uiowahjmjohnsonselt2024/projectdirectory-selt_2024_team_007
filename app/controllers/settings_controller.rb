# *********************************************************************
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
class SettingsController < ApplicationController
  before_action :set_current_user

  def add_billing_method
    @billing_method = @current_user.billing_methods.new(billing_method_params)

    if @billing_method.save
      flash[:success] = "Billing method added successfully."
    else
      flash[:danger] = @billing_method.errors.full_messages.join(", ")
    end

    redirect_to settings_path(active_tab: 'v-pills-billings')
  end

  def edit_billing_method
    @billing_method = @current_user.billing_methods.find(params[:id])

    if @billing_method.update(billing_method_params)
      flash[:success] = "Billing method updated successfully."
    else
      flash[:danger] = @billing_method.errors.full_messages.join(", ")
    end

    redirect_to settings_path(active_tab: 'v-pills-billings')
  end

  def delete_billing_method
    @billing_method = @current_user.billing_methods.find(params[:id])

    if @billing_method.destroy
      flash[:success] = "Billing method deleted successfully."
    else
      flash[:danger] = "Failed to delete billing method. Please try again."
    end

    redirect_to settings_path(active_tab: 'v-pills-billings')
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

  def settings
    @billing_methods = @current_user.billing_methods
    @billing_method = BillingMethod.new
    @orders = @current_user.orders.order(purchased_at: :desc) # Retrieve user orders
  end

  private

  def billing_method_params
    params.require(:billing_method).permit(:card_holder_name, :card_number, :expiration_date, :cvv)
  end

end
