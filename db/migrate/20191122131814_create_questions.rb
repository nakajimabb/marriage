class CreateQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :questions do |t|
      t.integer :question_type, null: false, limit: 1, unsigned: true
      t.integer :answer_type, null: false, limit: 1, unsigned: true
      t.text :content, null: false
      t.integer :min_answer_size, null: false, default: 1, limit: 1, unsigned: true
      t.integer :max_answer_size, null: false, default: 1, limit: 1, unsigned: true
      t.integer :rank, null: false
      t.references :created_by, null: false, foreign_key: true, foreign_key: { to_table: :users }
      t.references :updated_by, null: false, foreign_key: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
