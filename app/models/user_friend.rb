class UserFriend < ApplicationRecord
  belongs_to :user
  belongs_to :companion, class_name: 'User', foreign_key: :companion_id
end
