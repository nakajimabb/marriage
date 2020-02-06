# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(id: 1,
            nickname: 'admin',
            email: 'admin@special4.net',
            status: :active,
            first_name: '管理者',
            last_name: 'SP4',
            first_name_kana: 'カンリシャ',
            last_name_kana: 'スペシャル４',
            first_name_en: 'admin',
            last_name_en: 'SP4',
            sex: :male,
            religion: :christ,
            remark_self: 'xxx',
            role_courtship: true,
            role_matchmaker: true,
            role_head: true,
            birthday: Date.new(2000, 7, 20),
            lang: :ja,
            country: :jpn,
            zip: '575-0021',
            prefecture: :osaka,
            city: '四条畷',
            street: '南野',
            bio: 'システム管理者',
            drinking: :dont_drink,
            smoking: :dont_smoke,
            marital_status: :first_marriage,
            member_sharing: :shared_friend,
            blood: :type_b,
            education: '大学',
            job: 'SE',
            income: 1000,
            password: 'password',
            password_confirmation: 'password')
