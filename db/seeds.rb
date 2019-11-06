# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(id: 1,
            nickname: 'admin',
            email: 'nakajimabb@gmail.com',
            first_name: '管理者',
            last_name: 'admin',
            first_name_kana: 'カンリシャ',
            last_name_kana: '',
            first_name_en: 'administrator',
            last_name_en: '',
            sex: :male,
            religion: :christ,
            bio: 'システム管理者',
            role_courtship: true,
            role_matchmaker: true,
            role_head: true,
            password: 'password',
            password_confirmation: 'password')
