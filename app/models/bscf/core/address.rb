module Bscf
  module Core
    class Address < ApplicationRecord
      has_many :user_profiles
    end
  end
end
