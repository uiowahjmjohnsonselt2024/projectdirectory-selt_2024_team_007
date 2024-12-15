class AddQuestsToGameUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :game_users, :quests, :json, default: []
  end
end