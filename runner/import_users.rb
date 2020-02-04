# rails runner runner/import_users.rb runner/users.csv
require 'csv'
require 'miyabi'

file_name = ARGV[0]
row_num = 0
header = []
CSV.foreach(file_name, {encoding: 'BOM|UTF-8',}) do |row|
  if row_num == 0
    header = row
  else
    params = {lang: :ja, country: :jpn, status: :active}
    header.each_with_index do |key, i|
      column = key.strip.to_sym
      case column
      when :full_name
        params[:last_name], params[:first_name] = row[i].split(' ')
      when :full_name_kana
        params[:last_name_kana], params[:first_name_kana] = row[i].split(' ')
        nickname = params[:first_name_kana].to_roman
        if User.find_by_nickname(nickname)
          2.step(10) do |i|
            unless User.find_by_nickname(nickname + i.to_s)
              params[:nickname] = nickname + i.to_s
              break
            end
          end
        else
          params[:nickname] = nickname
        end
      when :sex
        params[:sex] = row[i] == '男' ? :male : :female
      when :prefecture
        params[:prefecture] = User.prefecture_code(row[i])
      when :blood
        params[:blood] = 'type_' + row[i].to_s.downcase
      when :hometown
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
