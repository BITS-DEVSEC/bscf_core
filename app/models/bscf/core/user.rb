module Bscf
  module Core
    class User < ApplicationRecord
      has_secure_password

      has_one :user_profile
      has_one :user_role
      has_one :business
      has_one :vehicle, foreign_key: :driver_id
      has_many :user_roles
      has_many :roles, through: :user_roles
      has_many :orders_placed, class_name: "Bscf::Core::Order", foreign_key: "ordered_by_id"
      has_many :orders_received, class_name: "Bscf::Core::Order", foreign_key: "ordered_to_id"

      validates :first_name, presence: true
      validates :middle_name, presence: true
      validates :last_name, presence: true
      validates :phone_number, presence: true
      validates :phone_number, uniqueness: true
      validates :email, uniqueness: true, allow_nil: true
      validates :password,
                presence: true,
                length: { is: 6 },
                format: {
                  with: /\A\d{6}\z/,
                  message: "must be exactly 6 digits"
                },
                if: :password_required?

      private

      def password_required?
        new_record? || password.present?
      end
    end
  end
end
