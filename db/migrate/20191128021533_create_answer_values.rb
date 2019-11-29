class CreateAnswerValues < ActiveRecord::Migration[6.0]
  def change
    create_table :answer_values do |t|
      t.references :question, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :value

      t.timestamps
    end
  end
end
