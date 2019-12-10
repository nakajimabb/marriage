# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
  include Rails.application.routes.url_helpers

  has_one_attached :avatar
  belongs_to :matchmaker, class_name: 'User', foreign_key: :matchmaker_id, optional: true
  belongs_to :created_by, class_name: 'User', foreign_key: :created_by_id, optional: true
  belongs_to :updated_by, class_name: 'User', foreign_key: :updated_by_id, optional: true
  has_many :members, dependent: :nullify, class_name: 'User', foreign_key: :matchmaker_id
  has_many :user_friends, dependent: :destroy
  has_many :friends, through: :user_friends, source: :companion
  has_many :eval_partners, dependent: :destroy
  has_one :requirement, dependent: :destroy

  enum sex: {male: 1, female: 2}
  enum religion: {christ: 1, buddhism: 2, islam: 3, hindu: 4, shinto: 5, taoism: 6, newage:7, secular: 8, other_religion: 10}
  enum blood: {type_a: 1, type_b: 2, type_o: 3, type_ab: 4}
  enum lang: {en: 41, ja: 73}
  enum drinking: {dont_drink: 1, do_drink: 2}
  enum smoking: {dont_smoke: 1, do_smoke: 2}
  enum marital_status: { first_marriage: 1, second_marriage: 2, married: 5 }
  enum member_sharing: { member_public: 1, shared_friend: 2 }
  enum country: Country::CODES
  enum prefecture: Prefecture::CODES

  validates :nickname, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :sex, presence: true
  validates :height, numericality: { only_integer: true, greater_than: 0, less_than: 256 }, allow_blank: true
  validates :weight, numericality: { only_integer: true, greater_than: 0, less_than: 256 }, allow_blank: true

  def self.prefecture_name(code)
    I18n.t('prefecture.' + code.to_s)
  end

  def self.prefecture_code(name)
    (Prefecture::CODES.find{ |code, _| I18n.translate('prefecture.' + code.to_s) == name } || [])[0]
  end

  def registrable_attributes(user)
    if role_head? || (role_matchmaker? && (user.nil? || user.matchmaker_id == self.id))
      attrs = %i(nickname email first_name last_name first_name_kana last_name_kana
                first_name_en last_name_en sex birthday tel fax mobile
                lang country zip prefecture city street building
                religion sect church baptized baptized_year
                role_courtship marital_status bio remark member_sharing
                income drinking smoking weight height job education hobby blood
                diseased disease_name password password_confirmation avatar)
      if role_head?
        attrs += %i(role_matchmaker matchmaker_id gene_partner_id)
      end
    elsif user.id == self.id
      attrs = %i(lang bio remark password password_confirmation)
    else
      attrs = []
    end
    attrs
  end

  def list_attributes
    if role_head? || role_matchmaker?
      attrs = %i(id nickname first_name last_name first_name_kana last_name_kana member_sharing
                sex age religion prefecture role_courtship role_matchmaker bio avatar_url)
    else
      attrs = %i(nickname sex age religion prefecture bio role_courtship
                role_courtship role_matchmaker avatar_url)
    end
    attrs
  end

  def public_attributes
    %i(nickname id sex age prefecture bio role_courtship
      blood weight height drinking smoking diseased disease_name
      religion sect church baptized baptized_year
      job education income hobby bio remark marital_status
      role_courtship role_matchmaker birthday
      courtships_size member_sharing avatar_url)
  end

  def avatar_url
    avatar.attached? ?  url_for(avatar) : nil
  end

  def full_name
    [last_name, first_name].compact.join(' ')
  end

  def age
    (Date.today.strftime('%Y%m%d').to_i - birthday.strftime('%Y%m%d').to_i) / 10000 if birthday
  end

  def courtships
    members.where(role_courtship: true)
  end

  def courtships_size
    courtships.size
  end

  def user_friend(user)
    if self.role_matchmaker? && user.role_matchmaker?
      user_friends.find_by(companion_id: user.id)
    end
  end

  def viewable_matchmaker_ids(delete_self=true)
    if role_matchmaker?
      matchmaker_ids = User.where(role_matchmaker: true, member_sharing: :member_public).pluck(:id)
      matchmaker_ids += user_friends.pluck(:companion_id)
      matchmaker_ids.delete(self.id) if delete_self
      matchmaker_ids.uniq
    end
  end

  def viewable?(user)
    if role_matchmaker?
      matchmaker_ids = viewable_matchmaker_ids(false)
      matchmaker_ids&.include?(user.matchmaker_id)
    end
  end

  def viewables
    if role_matchmaker?
      matchmaker_ids = viewable_matchmaker_ids
      User.where(role_courtship: true, matchmaker_id: matchmaker_ids)
    end
  end

  def partner_matches
    Requirement.matches(self, self.requirement)
  end

  # method overwrite => add avatar_url
  def token_validation_response
    response = super
    response[:courtships_size] = self.courtships_size
    response[:avatar_url] = self.avatar_url
    if self.role_matchmaker?
      response[:notification_count] = UserFriend.where(companion_id: self.id, status: :waiting).size
    end
    response
  end
end
