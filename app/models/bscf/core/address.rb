module Bscf
  module Core
    class Address < ApplicationRecord
      has_many :user_profiles

      # Associations for Delivery Orders where this address is a pickup point
      has_many :delivery_order_pickup_addresses, class_name: "Bscf::Core::DeliveryOrder", foreign_key: "pickup_address_id", inverse_of: :pickup_address
      # Associations for Delivery Orders where this address is a dropoff point
      has_many :delivery_order_dropoff_addresses, class_name: "Bscf::Core::DeliveryOrder", foreign_key: "dropoff_address_id", inverse_of: :dropoff_address

      validates :latitude, :longitude, presence: true, if: :requires_coordinates?



      def coordinates
        %i[latitude longitude] if latitude.present? && longitude.present?
      end

      private

      def requires_coordinates?
        delivery_order_pickup_addresses.any? || delivery_order_dropoff_addresses.any?
      end
    end
  end
end
