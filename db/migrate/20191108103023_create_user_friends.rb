class CreateUserFriends < ActiveRecord::Migration[6.0]
  def change
    create_table :user_friends do |t|
      t.references :user, null: false, foreign_key: true
      t.references :companion, null: false, foreign_key: true, foreign_key: { to_table: :users }
      t.boolean :authorized, null: false, default: false

      t.timestamps
    end
  end
end
