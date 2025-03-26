module Bscf
  module Core
    class Role < ApplicationRecord
      validates :name, presence: true
    end
  end
end
