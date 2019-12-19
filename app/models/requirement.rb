class Requirement < ApplicationRecord
  REGISTRABLE_ATTRIBUTES = %i(id user_id
                              min_age max_age required_age
                              religion required_religion
                              marital_status required_marital_status
                              min_income max_income required_income
                              min_height max_height required_height)

  belongs_to :user
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id, optional: true
  belongs_to :updated_by, class_name: 'User', foreign_key: :updated_by_id, optional: true

  enum religion: {christ: 1, buddhism: 2, islam: 3, hindu: 4, shinto: 5, taoism: 6, newage:7, secular: 8, other_religion: 10}
  enum marital_status: { first_marriage: 1, second_marriage: 2, married: 5 }

  validates :user_id, presence: true
  validates :min_age, numericality: { only_integer: true, greater_than: 18, less_than: 100 }, allow_blank: true
  validates :max_age, numericality: { only_integer: true, greater_than: 18, less_than: 100 }, allow_blank: true
  validates :min_income, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :max_income, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  validates :min_height, numericality: { only_integer: true, greater_than: 0, less_than: 256 }, allow_blank: true
  validates :max_height, numericality: { only_integer: true, greater_than: 0, less_than: 256 }, allow_blank: true

  def matched?(partner)
    if required_age? && (min_age || max_age)
      age = partner.age
      return false if !age
      return false if min_age && age < min_age
      return false if max_age && age > max_age
    end
    if required_religion? && religion
      return false if partner != religion
    end
    if required_marital_status? && marital_status
      return false if partner.marital_status != marital_status
    end
    if required_income? && (min_income || max_income)
      return false if !partner.income
      return false if min_income && partner.income < min_income
      return false if max_income && partner.income > max_income
    end
    if required_height? && (min_height || max_height)
      return false if !partner.height
      return false if min_height && partner.height < min_height
      return false if max_height && partner.height > max_height
    end
    true
  end

  def self.matches(user, requirement)
    if user && user.matchmaker_id && user.role_courtship? && requirement
      matchmaker = user.matchmaker
      sex = user.male? ? :female : :male
      users = matchmaker.viewables.where(sex: sex)
      if requirement.required_age?
        if requirement.min_age
          users = users.where('birthday < ?', requirement.min_age.years.before.to_date)
        end
        if requirement.max_age
          users = users.where('birthday > ?', requirement.max_age.years.before.to_date)
        end
      end
      if requirement.required_religion?
        if requirement.religion
          users = users.where(religion: requirement.religion)
        end
      end
      if requirement.required_marital_status?
        if requirement.marital_status
          users = users.where(marital_status: requirement.marital_status)
        end
      end
      if requirement.required_income?
        if requirement.min_income
          users = users.where('income >= ?', requirement.min_income)
        end
        if requirement.max_income
          users = users.where('income <= ?', requirement.max_income)
        end
      end
      if requirement.required_height?
        if requirement.min_height
          users = users.where('height >= ?', requirement.min_height)
        end
        if requirement.max_height
          users = users.where('height <= ?', requirement.max_height)
        end
      end
      users
    else
      Requirement.none
    end
  end
end
