# frozen_string_literal: true

class User < ActiveRecord::Base
  REGISTRABLE_ATTRIBUTES = %i(nickname email first_name last_name first_name_kana last_name_kana
                              first_name_en last_name_en sex birthday tel fax mobile
                              lang country zip prefecture city house_number
                              religion sect church baptized baptized_year
                              role_courtship role_matchmaker marital_status married bio remark
                              income drinking smoking weight height job education hobby blood
                              diseased disease_name gene_partner_id
                              password password_confirmation avatar)
  LIST_ATTRIBUTES = %i(id nickname first_name last_name sex age religion prefecture bio avatar_url)
  PUBLIC_ATTRIBUTES = %i(nickname sex age religion prefecture bio avatar_url)

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
  has_many :courtships, dependent: :nullify, class_name: 'User', foreign_key: :matchmaker_id

  enum sex: {male: 1, female: 2}
  enum religion: {christ: 1, buddhism: 2, islam: 3, hindu: 4, shinto: 5, taoism: 6, newage:7, secular: 8, other_religion: 10}
  enum blood: {type_a: 1, type_b: 2, type_o: 3, type_ab: 4}
  enum lang: {en: 41, ja: 73}
  enum drinking: {dont_drink: 1, do_drink: 2}
  enum smoking: {dont_smoke: 1, do_smoke: 2}
  enum marital_status: { first_marriage: 1, second_marriage: 2 }
  enum country: Country::CODES
  enum prefecture: Prefecture::CODES

  validates :email, presence: true, uniqueness: true
  validates :sex, presence: true
  validates :height, numericality: { only_integer: true, greater_than: 0, less_than: 256 }, allow_blank: true
  validates :weight, numericality: { only_integer: true, greater_than: 0, less_than: 256 }, allow_blank: true

  def avatar_url
    avatar.attached? ?  url_for(avatar) : nil
  end

  def age
    (Date.today.strftime('%Y%m%d').to_i - birthday.strftime('%Y%m%d').to_i) / 10000 if birthday
  end
end
