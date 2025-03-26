module Bscf
  module Core
    class User < ApplicationRecord
      has_secure_password

      has_one :user_profile
      has_many :user_roles
      has_many :roles, through: :user_roles

      validates :first_name, presence: true
      validates :middle_name, presence: true
      validates :last_name, presence: true
      validates :password, presence: true
      validates :phone_number, presence: true, uniqueness: true
      validates :email, presence: true, uniqueness: true
    end
  end
end
