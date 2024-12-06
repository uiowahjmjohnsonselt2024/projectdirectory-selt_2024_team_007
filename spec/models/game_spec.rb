# spec/models/game_spec.rb
require 'rails_helper'

RSpec.describe Game, type: :model do
  # Associations
  describe 'Associations' do
    it 'belongs to current_turn_user' do
      assoc = Game.reflect_on_association(:current_turn_user)
      expect(assoc.macro).to eq :belongs_to
      expect(assoc.options[:class_name]).to eq 'User'
      expect(assoc.options[:foreign_key]).to eq 'current_turn_user_id'
      expect(assoc.options[:optional]).to be true
    end

    it 'belongs to owner' do
      assoc = Game.reflect_on_association(:owner)
      expect(assoc.macro).to eq :belongs_to
      expect(assoc.options[:class_name]).to eq 'User'
      expect(assoc.options[:foreign_key]).to eq 'owner_id'
      expect(assoc.options[:optional]).to be true
    end

    it 'has many game_users' do
      assoc = Game.reflect_on_association(:game_users)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:dependent]).to eq :destroy
    end

    it 'has many users through game_users' do
      assoc = Game.reflect_on_association(:users)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:through]).to eq :game_users
    end

    it 'has many tiles' do
      assoc = Game.reflect_on_association(:tiles)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:dependent]).to eq :destroy
    end
  end

  # Validations
  describe 'Validations' do
    it 'is valid with valid attributes' do
      game = Game.new(name: "Test Game", join_code: "ABC123")
      expect(game).to be_valid
    end

    it 'is not valid without a name' do
      game = Game.new(join_code: "ABC123")
      expect(game).not_to be_valid
      expect(game.errors[:name]).to include("can't be blank")
    end

    it 'is not valid without a join_code' do
      game = Game.new(name: "Test Game")
      expect(game).not_to be_valid
      expect(game.errors[:join_code]).to include("can't be blank")
    end

    it 'is not valid with a non-unique join_code' do
      Game.create(name: "Existing Game", join_code: "ABC123")
      game = Game.new(name: "New Game", join_code: "ABC123")
      expect(game).not_to be_valid
      expect(game.errors[:join_code]).to include("has already been taken")
    end

    it 'is not valid with an improperly formatted join_code' do
      game = Game.new(name: "Test Game", join_code: "abc123")
      expect(game).not_to be_valid
      expect(game.errors[:join_code]).to include("must be 6 uppercase alphanumeric characters")
    end
  end

  # Callbacks
  describe 'Callbacks' do
    it 'normalizes the join_code before validation on create' do
      game = Game.new(name: "Test Game", join_code: " abc123 ")
      game.valid?
      expect(game.join_code).to eq("ABC123")
    end
  end
end