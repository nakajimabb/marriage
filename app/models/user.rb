# frozen_string_literal: true

class User < ActiveRecord::Base
  REGISTRABLE_ATTRIBUTES = %i(nickname email first_name last_name first_name_kana last_name_kana
                              first_name_en last_name_en sex birthday tel fax lang country zip prefecture city house_number
                              religion sect sect_name bio courtship matchmaker gene_partner
                              avatar password password_confirmation)

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
  include Rails.application.routes.url_helpers

  has_one_attached :avatar

  enum sex: {male: 1, female: 2}
  enum religion: {christ: 1, buddhism: 2, islam: 3, hindu: 4, shinto: 5, taoism: 6, secular: 50}
  enum lang: {en: 41, ja: 73}
  enum country: Country::COUNTRY

  validates :email, presence: true, uniqueness: true
  validates :sex, presence: true

  def avatar_url
    avatar.attached? ?  url_for(avatar) : nil
  end
end
