class CreateAnswerNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :answer_notes do |t|
      t.references :question, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :note

      t.timestamps
    end
  end
end
