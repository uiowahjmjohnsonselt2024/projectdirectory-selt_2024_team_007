class AddUidToUsers < ActiveRecord::Migration[7.2]
  # add uid when log-in using Google, if have more 3rd party, need to add provider
  def change
    add_column :users, :uid, :string
  end
end
