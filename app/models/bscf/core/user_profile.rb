module Bscf
  module Core
    class UserProfile < ApplicationRecord
      belongs_to :user
      belongs_to :verified_by, class_name: "Bscf::Core::User", optional: true
      belongs_to :address
      validates :date_of_birth, :nationality, :occupation, :source_of_funds, :gender, presence: true
    end
  end
end
