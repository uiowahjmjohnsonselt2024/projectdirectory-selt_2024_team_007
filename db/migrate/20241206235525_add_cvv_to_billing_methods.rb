class AddCvvToBillingMethods < ActiveRecord::Migration[7.2]
  def change
    add_column :billing_methods, :cvv, :string, null: false
  end
end
