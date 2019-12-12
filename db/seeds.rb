# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# User.create(id: 1,
#             nickname: 'admin',
#             email: 'admin@special4.net',
#             first_name: '管理者',
#             last_name: '',
#             first_name_kana: 'カンリシャ',
#             last_name_kana: '',
#             first_name_en: 'admin',
#             last_name_en: '',
#             sex: :male,
#             religion: :christ,
#             bio: 'システム管理者',
#             role_courtship: true,
#             role_matchmaker: true,
#             role_head: true,
#             birthday: Date.new(1975, 7, 20),
#             password: 'password',
#             password_confirmation: 'password')

Room.create(user_id: 1,
            name: 'お茶会',
            dated_on: Date.new(2020,2,2),
            room_type: :study,
            place: '永田町オフィス',
            min_age: 31,
            max_age: 40,
            male_count: 5,
            female_count: 5,
            remark: '新しい世界に飛び込む怖さや不安に関しては、2016年に上京したときのほうが強かった」[27]「（高校を卒業して女優に専念するので）とにかく女優を続けていくこと。自分に素直に、もっと感受性豊かに、いろいろな影響を受けながら、役に寄り添える（女優になりたいと思います）」[28]「（人に誇れるものがある人が）羨ましいとか、そういった劣等感が（活動の）原動力になっていると思います」[29]と述べている。また、『賭ケグルイ』で主演を務めたことで、特に性格面で「『楽しい』を表情に出せるようになり、他作品の現場でも『明るくなった』といわれるようになった」ことを述べている[30]。'
            )
Room.last.room_users.create(user_id: 2)
Room.last.room_users.create(user_id: 3)
Room.last.room_users.create(user_id: 4)
Room.last.room_users.create(user_id: 5)
Room.last.room_users.create(user_id: 6)
