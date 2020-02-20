# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(id: 1,
            code: 'admin',
            email: 'admin@special4.net',
            status: :fixed,
            first_name: '管理者',
            last_name: 'SP4',
            first_name_kana: 'カンリシャ',
            last_name_kana: 'スペシャル４',
            first_name_en: 'admin',
            last_name_en: 'SP4',
            sex: :male,
            religion: :christ,
            remark_self: 'xxx',
            remark_matchmaker: 'xxx',
            role_courtship: true,
            role_matchmaker: true,
            role_head: true,
            birthday: Date.new(2000, 1, 1),
            lang: :ja,
            country: :jpn,
            zip: 'xxx',
            prefecture: :osaka,
            city: 'xxx',
            street: 'xxx',
            bio: 'xxx',
            drinking: :dont_drink,
            smoking: :dont_smoke,
            marital_status: :first_marriage,
            member_sharing: :shared_friend,
            blood: :type_b,
            education: 'xxx',
            job: 'xxx',
            income: 1000,
            password: 'password',
            password_confirmation: 'password')
