class CreateTweets < ActiveRecord::Migration[7.2]
  def change
    create_table :tweets do |t|
      t.string :body
      t.references :user, null: false, foreign_key: true
      t.references :origin, foreign_key: { to_table: :tweets }

      t.timestamps
    end
  end
end
