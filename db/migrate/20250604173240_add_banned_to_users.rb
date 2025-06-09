class AddBannedToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :banned, :boolean, default: false, null: false
  end
end
