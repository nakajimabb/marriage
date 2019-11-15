class CreateEvalPartners < ActiveRecord::Migration[6.0]
  def change
    create_table :eval_partners do |t|
      t.references :user, null: false, foreign_key: true
      t.references :partner, null: false, foreign_key: true, foreign_key: { to_table: :users }
      t.integer :requirement_score, null: false, default: 0, limit: 1, unsigned: true
      t.boolean :permitted, null: false, default: false

      t.timestamps
    end
    add_index :eval_partners, [:user_id, :partner_id], unique: true
  end
end
