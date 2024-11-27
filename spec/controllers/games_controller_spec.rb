require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  # Override the email to ensure uniqueness
  let(:user) { create(:user, email: "unique_user_#{SecureRandom.hex(4)}@example.com") }

  before do
    # Simulate user being logged in by setting session[:session_token]
    session[:session_token] = user.session_token
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { { name: 'Epic Battle', join_code: 'G00001' } }

      it 'creates a new game' do
        expect {
          post :create, params: { game: valid_params }
        }.to change(Game, :count).by(1)
      end

      it 'associates the game with the current user as owner and current_turn_user' do
        post :create, params: { game: valid_params }
        game = Game.last
        expect(game.owner).to eq(user)
        expect(game.current_turn_user).to eq(user)
      end

      it 'creates a GameUser association for the creator' do
        expect {
          post :create, params: { game: valid_params }
        }.to change(GameUser, :count).by(1)
        game_user = GameUser.last
        expect(game_user.user).to eq(user)
        expect(game_user.game.name).to eq('Epic Battle')
        expect(game_user.health).to eq(100)
      end

      it 'redirects to the game show page with a success notice' do
        post :create, params: { game: valid_params }
        expect(response).to redirect_to(Game.last)
        expect(flash[:notice]).to eq('Game was successfully created.')
      end
    end

    context 'with invalid parameters' do
      context 'missing name' do
        let(:invalid_params) { { name: '', join_code: 'G00001' } }

        it 'does not create a new game' do
          expect {
            post :create, params: { game: invalid_params }
          }.not_to change(Game, :count)
        end

        it 'redirects to the root path with an alert' do
          post :create, params: { game: invalid_params }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to include("Name can't be blank")
        end
      end

      context 'duplicate join_code' do
        # Use the same owner_user to prevent duplicate emails
        let!(:existing_game) { create(:game, join_code: 'G00001', owner_user: user) }
        let(:invalid_params) { { name: 'Another Battle', join_code: 'G00001' } }

        it 'does not create a new game' do
          expect {
            post :create, params: { game: invalid_params }
          }.not_to change(Game, :count)
        end

        it 'redirects to the root path with an alert about join_code uniqueness' do
          post :create, params: { game: invalid_params }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to include('Join code has already been taken')
        end
      end

      context 'invalid join_code format' do
        let(:invalid_params) { { name: 'Epic Battle', join_code: 'G@0001' } }

        it 'does not create a new game' do
          expect {
            post :create, params: { game: invalid_params }
          }.not_to change(Game, :count)
        end

        it 'redirects to the root path with a format error alert' do
          post :create, params: { game: invalid_params }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to include('Join code must be 6 uppercase alphanumeric characters')
        end
      end
    end
  end

  describe 'POST #join' do
    # Create the game with the test user as owner to prevent duplicate emails
    let!(:game) { create(:game, join_code: 'G00002', owner_user: user) }
    let!(:other_user) { create(:user, email: "other_user_#{SecureRandom.hex(4)}@example.com") }

    context 'with a valid join_code' do
      it 'associates the user with the game' do
        expect {
          post :join, params: { join_code: 'G00002' }
        }.to change(GameUser, :count).by(1)
        game_user = GameUser.last
        expect(game_user.user).to eq(user)
        expect(game_user.game).to eq(game)
      end

      it 'redirects to the game show page with a success notice' do
        post :join, params: { join_code: 'G00002' }
        expect(response).to redirect_to(game)
        expect(flash[:notice]).to eq('You have successfully joined the game.')
      end
    end

    context 'with an invalid join_code' do
      it 'does not associate the user with any game' do
        expect {
          post :join, params: { join_code: 'INVALID' }
        }.not_to change(GameUser, :count)
      end

      it 'redirects to the root path with an alert' do
        post :join, params: { join_code: 'INVALID' }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Invalid join code.')
      end
    end

    context 'when the user has already joined the game' do
      before do
        create(:game_user, user: user, game: game)
      end

      it 'does not create a duplicate GameUser association' do
        expect {
          post :join, params: { join_code: 'G00002' }
        }.not_to change(GameUser, :count)
      end

      it 'redirects to the game show page with a notice' do
        post :join, params: { join_code: 'G00002' }
        expect(response).to redirect_to(game)
        expect(flash[:notice]).to eq('You have already joined this game.')
      end
    end
  end
end