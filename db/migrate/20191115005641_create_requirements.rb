class CreateRequirements < ActiveRecord::Migration[6.0]
  def change
    create_table :requirements do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :min_age, limit: 1, unsigned: true
      t.integer :max_age, limit: 1, unsigned: true
      t.boolean :required_age, null: false, default: false
      t.integer :religion, limit: 1
      t.boolean :required_religion, null: false, default: false
      t.integer :marital_status, limit: 1
      t.boolean :required_marital_status, null: false, default: false
      t.integer :min_income
      t.integer :max_income
      t.boolean :required_income, null: false, default: false
      t.integer :min_height, limit: 1, unsigned: true
      t.integer :max_height, limit: 1, unsigned: true
      t.boolean :required_height, null: false, default: false
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :updated_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
