require 'rails_helper.rb'

RSpec.describe SettingsController, type: :controller do
  let(:user) { create(:user, password: "password", email: "user@example.com") }
  let!(:billing_method) do
    BillingMethod.create!(
      user: user,
      card_number: "1234567812345678",
      card_holder_name: "John Doe",
      expiration_date: Date.today + 1.year,
      cvv: "235"
    )
  end

  before do
    allow(controller).to receive(:set_current_user) do
      controller.instance_variable_set(:@current_user, user)
    end
  end

  describe "PATCH #change_email" do
    context "with valid parameters" do
      it "updates the email when current password is correct" do
        patch :change_email, params: {
          current_password: "password",
          new_email: "new_email@example.com",
          confirm_email: "new_email@example.com"
        }
        expect(flash[:success]).to eq("Your email has been updated successfully.")
        expect(response).to redirect_to(settings_path)
        expect(user.reload.email).to eq("new_email@example.com")
      end
    end

    context "with invalid parameters" do
      it "does not update the email when emails do not match" do
        patch :change_email, params: {
          current_password: "password",
          new_email: "new_email@example.com",
          confirm_email: "different_email@example.com"
        }
        expect(flash[:danger]).to eq("Emails do not match.")
        expect(response).to redirect_to(settings_path)
        expect(user.reload.email).to eq("user@example.com") # Email remains unchanged
      end

      it "does not update the email when the current password is incorrect" do
        patch :change_email, params: {
          current_password: "wrong_password",
          new_email: "new_email@example.com",
          confirm_email: "new_email@example.com"
        }
        expect(flash[:danger]).to eq("Incorrect password. Please try again.")
        expect(response).to redirect_to(settings_path)
        expect(user.reload.email).to eq("user@example.com") # Email remains unchanged
      end

      it "does not update the email when current password is missing" do
        patch :change_email, params: {
          current_password: nil,
          new_email: "new_email@example.com",
          confirm_email: "new_email@example.com"
        }
        expect(flash[:danger]).to eq("Current password is required.")
        expect(response).to redirect_to(settings_path)
        expect(user.reload.email).to eq("user@example.com") # Email remains unchanged
      end
    end

    context "with database update failure" do
      before do
        allow_any_instance_of(User).to receive(:update_columns).and_return(false)
      end

      it "does not update the email and shows an error message" do
        patch :change_email, params: {
          current_password: "password",
          new_email: "new_email@example.com",
          confirm_email: "new_email@example.com"
        }
        expect(flash[:danger]).to eq("Failed to update email. Please try again.")
        expect(response).to redirect_to(settings_path)
        expect(user.reload.email).to eq("user@example.com") # Email remains unchanged
      end
    end
  end

  describe "PATCH #update_profile_image" do
    context "with a valid image" do
      it "updates the profile image successfully" do
        file = fixture_file_upload("app/assets/images/logo.png", "image/jpeg")
        patch :update_profile_image, params: { profile_image: file }
        expect(flash[:success]).to eq("Profile image updated successfully.")
        expect(response).to redirect_to(settings_path)
        expect(user.reload.profile_image).to be_attached
      end
    end

    context "without an image" do
      it "does not update the profile image and shows an error message" do
        patch :update_profile_image, params: { profile_image: nil }
        expect(flash[:danger]).to eq("No image selected.")
        expect(response).to redirect_to(settings_path)
        expect(user.reload.profile_image).not_to be_attached
      end
    end

    context "with a database update failure" do
      before do
        allow_any_instance_of(User).to receive(:update).and_return(false)
      end

      it "does not update the profile image and shows an error message" do
        file = fixture_file_upload("app/assets/images/logo.png", "image/jpeg")
        patch :update_profile_image, params: { profile_image: file }
        expect(flash[:danger]).to eq("Failed to update profile image. Please try again.")
        expect(response).to redirect_to(settings_path)
        expect(user.reload.profile_image).not_to be_attached
      end
    end
  end

  describe "PATCH #update_name" do
    context "with valid name" do
      it "updates the user's name" do
        patch :update_name, params: { name: "NewName" }
        expect(flash[:success]).to eq("Your name has been updated successfully.")
        expect(response).to redirect_to(settings_path)
        expect(user.reload.name).to eq("NewName")
      end
    end

    context "with invalid name" do
      it "does not update the user's name and shows an error message" do
        patch :update_name, params: { name: "" }
        expect(flash[:danger]).to eq("Failed to update your name.")
        expect(response).to redirect_to(settings_path)
        expect(user.reload.name).not_to eq("")
      end
    end
  end

  describe "GET #settings" do
    it "assigns billing methods and a new billing method" do
      get :settings
      expect(assigns(:billing_methods)).to eq([billing_method])
      expect(assigns(:billing_method)).to be_a_new(BillingMethod)
    end

    it "renders the settings template" do
      get :settings
      expect(response).to render_template(:settings)
    end
  end

  describe "POST #add_billing_method" do
    context "with valid attributes" do
      it "adds a new billing method and redirects to billings tab" do
        expect {
          post :add_billing_method, params: {
            billing_method: {
              card_number: "1234567812345876",
              card_holder_name: "John Doe",
              expiration_date: Date.today + 1.year,
              cvv: 542
            }
          }
        }.to change(BillingMethod, :count).by(1)
        expect(flash[:success]).to eq("Billing method added successfully.")
        expect(response).to redirect_to(settings_path(active_tab: 'v-pills-billings'))
      end
    end

    context "with invalid attributes" do
      it "does not add a billing method and redirects with error" do
        expect {
          post :add_billing_method, params: {
            billing_method: {
              card_number: nil,
              card_holder_name: "John Doe",
              expiration_date: Date.today + 1.year,
              cvv: nil
            }
          }
        }.to_not change(BillingMethod, :count)
        expect(flash[:danger]).to include("Card number can't be blank")
        expect(response).to redirect_to(settings_path(active_tab: 'v-pills-billings'))
      end
    end
  end

  describe "PATCH #edit_billing_method" do
    context "with valid attributes" do
      it "updates the billing method and redirects to billings tab" do
        patch :edit_billing_method, params: {
          id: billing_method.id,
          billing_method: {
            card_holder_name: "Updated Name"
          }
        }
        expect(flash[:success]).to eq("Billing method updated successfully.")
        expect(response).to redirect_to(settings_path(active_tab: 'v-pills-billings'))
        expect(billing_method.reload.card_holder_name).to eq("Updated Name")
      end
    end

    context "with invalid attributes" do
      it "does not update the billing method and redirects with error" do
        patch :edit_billing_method, params: {
          id: billing_method.id,
          billing_method: {
            card_number: "invalid"
          }
        }
        expect(flash[:danger]).to include("Card number must be exactly 16 digits")
        expect(response).to redirect_to(settings_path(active_tab: 'v-pills-billings'))
        expect(billing_method.reload.card_number).to_not eq("invalid")
      end
    end
  end

  describe "DELETE #delete_billing_method" do
    it "deletes the billing method and redirects to billings tab" do
      expect {
        delete :delete_billing_method, params: { id: billing_method.id }
      }.to change(BillingMethod, :count).by(-1)
      expect(flash[:success]).to eq("Billing method deleted successfully.")
      expect(response).to redirect_to(settings_path(active_tab: 'v-pills-billings'))
    end
  end

end
