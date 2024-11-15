require 'rails_helper.rb'

RSpec.describe UsersController, type: :controller do
  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post :create, params: { user: { name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password" } }
        }.to change(User, :count).by(1)
      end

      it "redirects to the login path" do
        post :create, params: { user: { name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password" } }
        expect(response).to redirect_to(login_path)
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post :create, params: { user: { name: "", email: "invalid_email", password: "short", password_confirmation: "different" } }
        }.to_not change(User, :count)
      end

      it "renders the 'new' template" do
        post :create, params: { user: { name: "", email: "invalid_email", password: "short", password_confirmation: "different" } }
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET #show" do
    let(:user) { User.create(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password") }

    context "when user is logged in" do
      before do
        allow(controller).to receive(:set_current_user).and_return(user)
        allow(controller).to receive(:current_user?).and_return(true)
      end

      it "returns a success response" do
        get :show, params: { id: user.id }
        expect(response).to be_successful
      end
    end

    context "when user is not logged in" do
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

      it "sets a flash warning" do
        get :show, params: { id: user.id + 1 }
        expect(flash[:warning]).to eq('Can only show profile of logged-in user')
      end
    end
  end
end
