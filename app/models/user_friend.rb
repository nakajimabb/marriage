class UserFriend < ApplicationRecord
  belongs_to :user
  belongs_to :companion, class_name: 'User', foreign_key: :companion_id

  enum status: { waiting: 1, accepted: 2, rejected: 3, pending: 4 }

  validates :user_id, presence: true
  validates :companion_id, presence: true

  def user_name
    user&.nickname
  end

  def user_avatar_url
    user&.avatar_url
  end
end
