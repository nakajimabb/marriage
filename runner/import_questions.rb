# rails runner runner/import_questions.rb runner/questions.csv family_relationship
require 'csv'

file_name = ARGV[0]
question_type = ARGV[1]
admin = User.find_by_nickname('admin')

rank = 1
CSV.foreach(file_name, {encoding: 'BOM|UTF-8',}) do |row|
  value = 1
  question = nil
  row.each_with_index do |col, i|
  if i == 0
    question = Question.create(question_type: question_type, answer_type: :number, content: col, rank: rank,
                               min_answer_size: 1, max_answer_size: 1, created_by_id: admin.id, updated_by_id: admin.id)
  else
    question.question_choices.create(label: col, value: value)
    value += 1
  end
  end
  rank += 1
end

puts rank
