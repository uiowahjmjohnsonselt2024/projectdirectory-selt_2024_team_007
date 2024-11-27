require 'rails_helper.rb'

RSpec.describe UsersController, type: :controller do

  # Happy Path: GET #new successfully returns a response
  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      # Happy Path: User is created successfully
      it "creates a new User" do
        post :create, params: { user: { name: "JohnDoe", email: "john.doe@example.com", password: "password", password_confirmation: "password" } }

        # Check if the user instance is valid
        expect(assigns(:user)).to be_valid

        # Test the change in User count
        expect {
          post :create, params: { user: { name: "JaneDoe", email: "jane.doe@example.com", password: "password123", password_confirmation: "password123" } }
        }.to change(User, :count).by(1)
      end

      # Happy Path: Redirects to the login path after user creation
      it "redirects to the login path" do
        post :create, params: { user: { name: "JohnDoe", email: "john.doe@example.com", password: "password", password_confirmation: "password" } }
        expect(response).to redirect_to(login_path)
      end
    end

    context "with invalid parameters" do
      # Sad Path: Does not create a user with invalid parameters
      it "does not create a new User" do
        expect {
          post :create, params: { user: { name: "", email: "", password: "", password_confirmation: "" } }
        }.to change(User, :count).by(0)
      end

      # Sad Path: Renders the 'new' template with invalid parameters
      it "renders the 'new' template" do
        post :create, params: { user: { name: "", email: "", password: "", password_confirmation: "" } }
        expect(response).to render_template('new')
      end
    end
  end

  describe "GET #show" do
    let(:user) { User.create(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password") }

    context "when user is logged in" do
      before do
        allow(controller).to receive(:set_current_user).and_return(user)
        allow(controller).to receive(:current_user?).and_return(true)
      end

      # Happy Path: User can view their own profile
      it "returns a success response" do
        get :show, params: { id: user.id }
        expect(response).to be_successful
      end
    end

    context "when user is not logged in" do
      # Sad Path: Redirects to the login path when not logged in
      it "redirects to the login path" do
        get :show, params: { id: user.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when user tries to access another user's profile" do
      before do
        allow(controller).to receive(:set_current_user).and_return(user)
        allow(controller).to receive(:current_user?).and_return(false)
      end

      # Sad Path: Flash warning when accessing another user's profile
      it "sets a flash warning" do
        get :show, params: { id: user.id + 1 }
        expect(flash[:warning]).to eq('Can only show profile of logged-in user')
      end
    end
  end

  let!(:user) { User.create!(name: "JohnDoe", email: "john@example.com", password: "password", password_confirmation: "password") }
  let!(:another_user) { User.create!(name: "JaneSmith", email: "jane@example.com", password: "password", password_confirmation: "password") }

  before do
    # Simulate setting the current user
    controller.instance_variable_set(:@current_user, user)
  end

  describe "#current_user?" do
    # Happy Path: Returns true when the ID matches the current user's ID
    it "returns true when the id matches the current user's id" do
      expect(controller.send(:current_user?, user.id.to_s)).to be true
    end

    # Sad Path: Returns false when the ID does not match the current user's ID
    it "returns false when the id does not match the current user's id" do
      expect(controller.send(:current_user?, another_user.id.to_s)).to be false
    end
  end
end
