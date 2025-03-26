module Bscf
  module Core
    class UserRole < ApplicationRecord
      belongs_to :user
      belongs_to :role
    end
  end
end
