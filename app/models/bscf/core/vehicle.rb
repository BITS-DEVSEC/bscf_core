module Bscf::Core
  class Vehicle < ApplicationRecord
    belongs_to :driver, class_name: "Bscf::Core::User", optional: true

    validates :plate_number, presence: true, uniqueness: { case_sensitive: false }
    validates :vehicle_type, presence: true
    validates :brand, presence: true
    validates :model, presence: true
    validates :year, presence: true, numericality: { only_integer: true, greater_than: 1900, less_than_or_equal_to: Time.current.year }
    validates :color, presence: true
  end
end
