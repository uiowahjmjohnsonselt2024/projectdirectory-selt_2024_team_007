class AddGenreSettingAndChatImageUrlToGames < ActiveRecord::Migration[7.2]
  def change
    add_column :games, :genre, :string
    add_column :games, :setting, :string
    add_column :games, :chat_image_url, :text
  end
end
