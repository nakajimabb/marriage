class Room < ApplicationRecord
  REGISTRABLE_ATTRIBUTES = %w(name room_type dated_on fixed_on min_age max_age male_count female_count prefecture address remark)
  belongs_to :user
  has_many :room_users, dependent: :destroy
  has_many :users, through: :room_users

  enum room_type: {tea: 1, meal: 2, study: 3}
  enum prefecture: Prefecture::CODES

  validates :room_type, presence: true
  validates :dated_on, presence: true
  validates :fixed_on, presence: true
  validates :min_age, presence: true, numericality: { only_integer: true, greater_than: 18, less_than: 100 }
  validates :max_age, presence: true, numericality: { only_integer: true, greater_than: 18, less_than: 100 }
  validates :male_count, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 255 }
  validates :female_count, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 255 }
  validates :prefecture, presence: true
  validate  :dated_on_not_before_today, :fixed_on_not_after_dated_on

  def dated_on_not_before_today
    errors.add(:dated_on, "は本日以降のものを選択してください") if dated_on && dated_on < Date.today
  end

  def fixed_on_not_after_dated_on
    errors.add(:fixed_on, "は実施日以前のものを選択してください") if fixed_on && dated_on < fixed_on
  end

  def availability(user)
    age = user.age
    today = Date.today
    if dated_on < today
      :finished
    elsif self.user_id == user.id
      :created
    else
      if room_users.where(user_id: user.id).exists?
        :joined
      else
        if !user.birthday || age > max_age || age < min_age
          :invalid_age
        elsif fixed_on < today
          :fixed
        else
          if user.male?
            (male_count <= male_users_size) ? :full : :registrable
          else
            (female_count <= female_users_size) ? :full : :registrable
          end
        end
      end
    end
  end

  def male_users
    users.where(sex: :male)
  end

  def female_users
    users.where(sex: :female)
  end

  def male_users_size
    users.where(sex: :male).size
  end

  def female_users_size
    users.where(sex: :female).size
  end
end
