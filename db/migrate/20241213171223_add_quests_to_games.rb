class AddQuestsToGames < ActiveRecord::Migration[7.2]
  def change
    add_column :games, :quests, :text
  end
end
