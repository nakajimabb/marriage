class CreateRooms < ActiveRecord::Migration[6.0]
  def change
    create_table :rooms do |t|
      t.integer :room_type
      t.date :dated_on, null: false
      t.date :fixed_on, null: false
      t.string :name
      t.text :remark
      t.integer :prefecture, limit: 2
      t.string :address
      t.references :user, null: false, foreign_key: true
      t.integer :min_age, limit: 1, unsigned: true
      t.integer :max_age, limit: 1, unsigned: true
      t.integer :male_count, null: false, limit: 1, unsigned: true
      t.integer :female_count, null: false, limit: 1, unsigned: true

      t.timestamps
    end
  end
end
