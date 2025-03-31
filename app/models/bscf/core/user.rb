module Bscf
  module Core
    class User < ApplicationRecord
      has_secure_password

      has_one :user_profile
      has_one :user_role
      has_many :user_roles
      has_many :roles, through: :user_roles

      has_many :orders_placed, class_name: "Bscf::Core::Order", foreign_key: "ordered_by_id"
      has_many :orders_received, class_name: "Bscf::Core::Order", foreign_key: "ordered_to_id"

      validates :first_name, presence: true
      validates :middle_name, presence: true
      validates :last_name, presence: true
      validates :password, presence: true
      validates :phone_number, presence: true, uniqueness: true
      validates :email, presence: true, uniqueness: true
    end
  end
end
