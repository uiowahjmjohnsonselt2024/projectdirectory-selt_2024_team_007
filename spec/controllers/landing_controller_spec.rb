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
require 'rails_helper'

RSpec.describe LandingController, type: :controller do
  render_views
  # Create a user with a unique email to prevent duplication errors
  let(:user) { create(:user, email: "unique_user_#{SecureRandom.hex(4)}@example.com") }

  # Create additional users with unique emails if needed
  let(:other_user) { create(:user, email: "other_user_#{SecureRandom.hex(4)}@example.com") }

  # Create games and associate them with the user via GameUser
  let!(:game1) { create(:game, join_code: 'G00003', owner_user: user) }
  let!(:game2) { create(:game, join_code: 'G00004', owner_user: user) }
  let!(:game3) { create(:game, join_code: 'G00005', owner_user: other_user) }

  before do
    # Simulate user being logged in by setting session[:session_token]
    session[:session_token] = user.session_token

    # Associate user with game1 and game2 via GameUser
    create(:game_user, user: user, game: game1)
    create(:game_user, user: user, game: game2)

    # Optionally, associate other_user with game3 if needed
    create(:game_user, user: other_user, game: game3)
  end

  describe 'GET #index' do
    context 'when user is logged in and has joined games' do
      it 'assigns the user\'s games to @games ordered by created_at descendingly' do
        get :index
        expect(assigns(:games)).to eq([game2, game1]) # Assuming game2 was created after game1
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context 'when user is logged in but has not joined any games' do
      before do
        # Remove any GameUser associations for the user
        GameUser.where(user: user).destroy_all
      end

      it 'assigns an empty array to @games' do
        get :index
        expect(assigns(:games)).to be_empty
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'displays a message indicating no games have been joined' do
        get :index
        expect(response.body).to include('No games available. Create one!')
      end
    end

    context 'when user is not logged in' do
      before do
        # Simulate user being logged out
        session[:session_token] = nil
      end

      it 'redirects to the login path' do
        get :index
        expect(response).to redirect_to(login_path)
      end
    end
  end
end