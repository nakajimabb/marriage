class CreateUserFriends < ActiveRecord::Migration[6.0]
  def change
    create_table :user_friends do |t|
      t.references :user, null: false, foreign_key: true
      t.references :companion, null: false, foreign_key: true, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 1, limit: 1

      t.timestamps
    end
    add_index :user_friends, [:user_id, :companion_id], unique: true
  end
end
