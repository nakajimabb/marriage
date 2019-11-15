# runner/import_users.rb runner/users.csv
require 'csv'

file_name = ARGV[0]
row_num = 0
header = []
CSV.foreach(file_name, {encoding: 'BOM|UTF-8',}) do |row|
  if row_num == 0
    header = row
  else
    params = {}
    header.each_with_index do |key, i|
      column = key.strip.to_sym
      case column
      when :full_name
        params[:last_name], params[:first_name] = row[i].split(' ')
      when :full_name_kana
        params[:last_name_kana], params[:first_name_kana] = row[i].split(' ')
        params[:nickname] = params[:first_name_kana].to_roman
      when :sex
        params[:sex] = row[i] == '男' ? :male : :female
      when :prefecture, :hometown, :blood
      when :role_courtship, :role_matchmaker
        params[column] = row[i] == 'TRUE'
      else
        params[column] = row[i]
      end
    end
    params[:password] = params[:password_confirmation] = 'password'
    User.create(params)
  end
  row_num += 1
end
