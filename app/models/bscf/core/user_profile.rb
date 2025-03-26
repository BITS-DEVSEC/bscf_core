module Bscf
  module Core
    class UserProfile < ApplicationRecord
      belongs_to :user
      belongs_to :address
      belongs_to :verified_by, class_name: "User", optional: true

      validates :date_of_birth, presence: true
      validates :nationality, presence: true
      validates :occupation, presence: true
      validates :source_of_funds, presence: true
      validates :gender, presence: true
    end
  end
end
