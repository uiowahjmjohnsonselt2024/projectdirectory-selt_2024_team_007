require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { create(:user, email: "unique_user_#{SecureRandom.hex(4)}@example.com") }
  let(:friend1) { create(:user) }
  let(:friend2) { create(:user) }
  let(:friend3) { create(:user) }
  let(:friend4) { create(:user) }
  let(:game) { create(:game, owner: user) }

  before do
    session[:session_token] = user.session_token
    user.friends << [friend1, friend2, friend3]
  end

  describe 'POST #create' do
    let(:valid_params) { { name: 'Epic Battle', join_code: 'G00001', map_size: '6x6' } }

    context 'with valid parameters' do
      before { user.update_column(:shards_balance, 600) }

      it 'creates a new game' do
        expect {
          post :create, params: { game: valid_params }
        }.to change(Game, :count).by(1)
      end

      it 'reduces the user’s shard balance by 40' do
        post :create, params: { game: valid_params }
        expect(user.reload.shards_balance).to eq(560)
      end

      it 'sets a success flash message' do
        post :create, params: { game: valid_params }
        expect(flash[:notice]).to eq('Game was successfully created.')
      end
    end

    context 'when the user has insufficient shards' do
      before { user.update_column(:shards_balance, 30) }

      it 'does not create a new game' do
        expect {
          post :create, params: { game: valid_params }
        }.not_to change(Game, :count)
      end

      it 'renders the landing page with an error message' do
        post :create, params: { game: valid_params }
        expect(response).to redirect_to('/landing')
        expect(flash[:error]).to eq('Insufficient Shards Balance')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { join_code: 'G00001', map_size: '6x6' } }

      before { user.update_column(:shards_balance, 600) }

      it 'does not create a new game' do
        expect {
          post :create, params: { game: invalid_params }
        }.not_to change(Game, :count)
      end

      it 'does not change the user’s shard balance' do
        post :create, params: { game: invalid_params }
        expect(user.reload.shards_balance).to eq(600)
      end

      it 'renders the landing page with an error message' do
        post :create, params: { game: invalid_params }
        expect(response).to render_template('landing/index') # Expect template rendering
        expect(response).to have_http_status(:unprocessable_entity) # Expect 422 status
        expect(flash[:danger]).to eq('An error occurred.') # Check flash message
      end
    end
  end

  describe 'POST #invite_friends' do
    before do
      controller.instance_variable_set(:@game, game)
      allow(controller).to receive(:ensure_owner)
    end

    context 'when inviting valid friends' do
      it 'adds friends to the game' do
        expect {
          post :invite_friends, params: { id: game.id, friend_ids: [friend1.id, friend2.id] }
        }.to change(GameUser, :count).by(2)

        expect(game.users).to include(friend1, friend2)
        expect(flash[:notice]).to eq('Friends successfully added to the game.')
      end

      it 'does not add duplicate friends already in the game' do
        game.users << friend1

        expect {
          post :invite_friends, params: { id: game.id, friend_ids: [friend1.id, friend2.id] }
        }.to change(GameUser, :count).by(1)

        expect(game.users).to include(friend2)
        expect(flash[:notice]).to eq('Friends successfully added to the game.')
      end
    end

    context 'when inviting more than 3 friends' do
      it 'does not add friends and redirects with an alert' do
        post :invite_friends, params: { id: game.id, friend_ids: [friend1.id, friend2.id, friend3.id, friend4.id] }

        expect(game.users).not_to include(friend4)
        expect(flash[:alert]).to eq('You can invite up to 3 friends.')
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when total players exceed 4' do
      it 'does not add friends and redirects with an alert' do
        # Create a new game for this test
        test_game = create(:game, owner: user)

        # Add one user to the game manually
        test_game.users << friend1
        test_game.reload

        # First invite: Add two more users (total = 3 including owner)
        post :invite_friends, params: { id: test_game.id, friend_ids: [friend2.id, friend3.id] }
        test_game.reload

        # Second invite: Attempt to add a 4th user (exceeding the limit)
        post :invite_friends, params: { id: test_game.id, friend_ids: [friend4.id] }
        test_game.reload

        # Validate that the 4th friend was not added
        expect(test_game.users).not_to include(friend4)

        # Validate redirection
        expect(response).to redirect_to(root_path)
      end
    end




    context 'when inviting non-friends' do
      let(:non_friend) { create(:user) }

      it 'ignores non-friends and only adds valid friends' do
        expect {
          post :invite_friends, params: { id: game.id, friend_ids: [friend1.id, non_friend.id] }
        }.to change(GameUser, :count).by(1)

        expect(game.users).to include(friend1)
        expect(game.users).not_to include(non_friend)
        expect(flash[:notice]).to eq('Friends successfully added to the game.')
      end
    end
  end

  describe 'ensure_owner' do
    context 'when the current user is not the game owner' do
      let(:other_user) { create(:user) }

      before do
        session[:session_token] = other_user.session_token
        controller.instance_variable_set(:@game, game)
      end

      it 'redirects to root with an alert' do
        expect(controller).to receive(:redirect_to).with(root_path)
        expect {
          controller.send(:ensure_owner)
        }.to change { flash[:alert] }.to('You are not authorized to add friends to this game.')
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

  describe 'POST #move' do

    before do
      game.game_users.create(user: user, health: 100, current_tile_id: nil)
    end

    context 'when tile does not exist or update fails' do
      it 'returns unprocessable_entity' do
        post :move, params: { id: game.id, x: 999, y: 999 }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #leave' do
    context 'when user is part of the game' do
      before { game.game_users.create(user: user, health: 100) }

      it 'removes the user from the game and sets a success notice' do
        expect {
          get :leave, params: { id: game.id }
        }.to change(GameUser, :count).by(-1)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('You have successfully left the game.')
      end
    end

    context 'when user is not part of the game' do
      it 'does not remove anyone and sets a flash alert' do
        expect {
          get :leave, params: { id: game.id }
        }.not_to change(GameUser, :count)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not part of this game.')
      end
    end
  end

  describe 'POST #chat' do
    let(:game_user) { create(:game_user, game: game, user: user, health: 100) }
    let(:gpt_service_double) { instance_double(GptDmService) }

    before do
      game_user # create the association
      # Stub external GPT service calls
      allow(GptDmService).to receive(:new).and_return(gpt_service_double)
      allow(gpt_service_double).to receive(:summarize_conversation).and_return("Summarized history")
      allow(gpt_service_double).to receive(:generate_dm_response).and_return("GPT reply")
      allow(gpt_service_double).to receive(:generate_image_prompt).and_return("Refined image prompt")
      allow(gpt_service_double).to receive(:generate_image).and_return("http://example.com/generated_image.png")

      # Stub the broadcast
      allow(ChatChannel).to receive(:broadcast_to)
    end

    context 'when user is part of the game' do
      it 'processes the chat message, updates the game context, and broadcasts the message' do
        post :chat, params: { id: game.id, message: "Hello, world!" }
        expect(response).to have_http_status(:ok)

        # Check that the GPT response was appended
        game.reload
        context_messages = JSON.parse(game.context)
        expect(context_messages.last).to include("role" => "assistant", "content" => "GPT reply")

        # Check broadcast
        expect(ChatChannel).to have_received(:broadcast_to).with(game, hash_including(gpt_response: "GPT reply"))
      end
    end

    context 'when user is not part of the game' do
      let(:other_user) { create(:user) }

      before do
        session[:session_token] = other_user.session_token
      end

      it 'returns forbidden and does not process chat' do
        post :chat, params: { id: game.id, message: "Hello, world!" }
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to eq({ "error" => "You are not authorized to chat in this game." })
      end
    end
  end

  # Test authorize_game_user independently (if desired)
  describe 'authorize_game_user' do
    let(:other_user) { create(:user) }
    before do
      session[:session_token] = other_user.session_token
      # We do not create a GameUser record for `other_user` in this game
    end

    it 'renders forbidden json when user is not part of the game' do
      post :chat, params: { id: game.id, message: "Check auth" }
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)).to eq({ "error" => "You are not authorized to chat in this game." })
    end
  end

end