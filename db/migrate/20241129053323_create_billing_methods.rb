class CreateBillingMethods < ActiveRecord::Migration[7.2]
  def change
    create_table :billing_methods do |t|
      t.references :user, null: false, foreign_key: true
      t.string :card_number
      t.string :card_holder_name
      t.date :expiration_date

      t.timestamps
    end
  end
end
