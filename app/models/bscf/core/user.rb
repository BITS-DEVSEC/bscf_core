module Bscf
  module Core
    class User < ApplicationRecord
      has_secure_password

      validates :first_name, :middle_name, :last_name, :password_digest, presence: true
      validates :email, :phone_number, uniqueness: true, presence: true
    end
  end
end
