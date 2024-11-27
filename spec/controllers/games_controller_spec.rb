require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { create(:user, email: "unique_user_#{SecureRandom.hex(4)}@example.com") }

  before do
    session[:session_token] = user.session_token
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { 
        { 
          name: 'Epic Battle', 
          join_code: 'G00001',
          map_size: '6x6' 
        } 
      }

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

      it 'creates a game with valid map size' do
        post :create, params: { game: valid_params }
        expect(Game.last.map_size).to eq('6x6')
      end
    end

    context 'with invalid parameters' do
      context 'missing name' do
        let(:invalid_params) { { join_code: 'G00001', map_size: '6x6' } }

        it 'does not create a new game' do
          expect {
            post :create, params: { game: invalid_params }
          }.not_to change(Game, :count)
        end

        it 'renders landing page with errors' do
          post :create, params: { game: invalid_params }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template('landing/index')
        end
      end

      context 'duplicate join_code' do
        let!(:existing_game) { create(:game, join_code: 'G00001', owner: user) }
        let(:invalid_params) { 
          { 
            name: 'Another Battle', 
            join_code: 'G00001',
            map_size: '6x6'
          } 
        }

        it 'does not create a new game' do
          expect {
            post :create, params: { game: invalid_params }
          }.not_to change(Game, :count)
        end

        it 'renders landing page with errors' do
          post :create, params: { game: invalid_params }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template('landing/index')
        end
      end

      context 'invalid map size format' do
        let(:invalid_params) { 
          { 
            name: 'Epic Battle', 
            join_code: 'G00001',
            map_size: '6' 
          } 
        }

        it 'does not create a new game' do
          expect {
            post :create, params: { game: invalid_params }
          }.not_to change(Game, :count)
        end

        it 'renders landing page with errors' do
          post :create, params: { game: invalid_params }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template('landing/index')
        end
      end

      context 'map size too small' do
        let(:invalid_params) { 
          { 
            name: 'Epic Battle', 
            join_code: 'G00001',
            map_size: '4x4' 
          } 
        }

        it 'does not create a new game' do
          expect {
            post :create, params: { game: invalid_params }
          }.not_to change(Game, :count)
        end

        it 'renders landing page with errors' do
          post :create, params: { game: invalid_params }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template('landing/index')
        end
      end
    end
  end

  describe 'POST #join' do
    let!(:game) { create(:game, join_code: 'G00002', owner: user) }

    context 'with valid join_code' do
      it 'associates the user with the game' do
        expect {
          post :join, params: { join_code: 'G00002' }
        }.to change(GameUser, :count).by(1)
        game_user = GameUser.last
        expect(game_user.user).to eq(user)
        expect(game_user.game).to eq(game)
      end

      it 'redirects to game show page with success notice' do
        post :join, params: { join_code: 'G00002' }
        expect(response).to redirect_to(game)
        expect(flash[:notice]).to eq('You have successfully joined the game.')
      end
    end

    context 'with invalid join_code' do
      it 'does not create game user association' do
        expect {
          post :join, params: { join_code: 'INVALID' }
        }.not_to change(GameUser, :count)
      end

      it 'redirects to root with error' do
        post :join, params: { join_code: 'INVALID' }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Invalid join code.')
      end
    end

    context 'when user already joined' do
      before do
        create(:game_user, user: user, game: game)
      end

      it 'does not create duplicate association' do
        expect {
          post :join, params: { join_code: 'G00002' }
        }.not_to change(GameUser, :count)
      end

      it 'redirects to game with notice' do
        post :join, params: { join_code: 'G00002' }
        expect(response).to redirect_to(game)
        expect(flash[:notice]).to eq('You have already joined this game.')
      end
    end
  end

  describe 'GET #show' do
    let!(:game) { create(:game, owner: user) }
    
    it 'assigns requested game' do
      get :show, params: { id: game.id }
      expect(assigns(:game)).to eq(game)
    end

    it 'assigns game users' do
      game_user = create(:game_user, game: game, user: user)
      get :show, params: { id: game.id }
      expect(assigns(:game_users)).to include(game_user)
    end

    context 'when game not found' do
      it 'redirects to root with error' do
        get :show, params: { id: -1 }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Game not found.')
      end
    end
  end
end