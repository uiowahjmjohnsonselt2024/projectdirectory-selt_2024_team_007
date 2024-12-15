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

RSpec.describe GameUser, type: :model do
  describe 'Associations' do
    it 'belongs to game' do
      assoc = GameUser.reflect_on_association(:game)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'belongs to user' do
      assoc = GameUser.reflect_on_association(:user)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'belongs to current_tile' do
      assoc = GameUser.reflect_on_association(:current_tile)
      expect(assoc.macro).to eq :belongs_to
      expect(assoc.options[:class_name]).to eq 'Tile'
      expect(assoc.options[:foreign_key]).to eq 'current_tile_id'
      expect(assoc.options[:optional]).to be true
    end
  end

  describe 'Validations' do
    let(:game) { Game.create(name: "Test Game", join_code: "ABC123") }
    let(:user) { User.create(name: "Test User", email: "test@example.com", password: "password", password_confirmation: "password") }
    let(:tile) { Tile.create(game: game, x_coordinate: 0, y_coordinate: 0, tile_type: 'normal') }

    let(:valid_attributes) do
      {
        game: game,
        user: user,
        current_tile: tile,
        health: 100
      }
    end

    it 'is valid with valid attributes' do
      game_user = GameUser.new(valid_attributes)
      expect(game_user).to be_valid
    end

    it 'is valid without health' do
      game_user = GameUser.new(valid_attributes.except(:health))
      expect(game_user).to be_valid
    end

    it 'is valid without current_tile' do
      game_user = GameUser.new(valid_attributes.except(:current_tile))
      expect(game_user).to be_valid
    end

    it 'is not valid without game' do
      game_user = GameUser.new(valid_attributes.except(:game))
      expect(game_user).not_to be_valid
      expect(game_user.errors[:game]).to include("must exist")
    end

    it 'is not valid without user' do
      game_user = GameUser.new(valid_attributes.except(:user))
      expect(game_user).not_to be_valid
      expect(game_user.errors[:user]).to include("must exist")
    end

    context 'health validation' do
      it 'is not valid with negative health' do
        game_user = GameUser.new(valid_attributes.merge(health: -1))
        expect(game_user).not_to be_valid
        expect(game_user.errors[:health]).to include("must be greater than or equal to 0")
      end

      it 'is valid with zero health' do
        game_user = GameUser.new(valid_attributes.merge(health: 0))
        expect(game_user).to be_valid
      end

      it 'is valid with positive health' do
        game_user = GameUser.new(valid_attributes.merge(health: 100))
        expect(game_user).to be_valid
      end
    end
  end
end