class CreateQuestionChoices < ActiveRecord::Migration[6.0]
  def change
    create_table :question_choices do |t|
      t.references :question, null: false, foreign_key: true
      t.string :label
      t.integer :value

      t.timestamps
    end
  end
end
