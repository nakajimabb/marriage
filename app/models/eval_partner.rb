class EvalPartner < ApplicationRecord
  belongs_to :user
  belongs_to :partner, class_name: 'User', foreign_key: :partner_id, optional: true
end
