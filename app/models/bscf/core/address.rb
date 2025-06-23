module Bscf
  module Core
    class Address < ApplicationRecord
      has_many :user_profiles

      # Add associations for delivery orders and items
      has_many :delivery_order_pickups, class_name: "Bscf::Core::DeliveryOrder", foreign_key: "pickup_address_id"
      has_many :delivery_order_item_pickups, class_name: "Bscf::Core::DeliveryOrderItem", foreign_key: "pickup_address_id"
      has_many :delivery_order_item_dropoffs, class_name: "Bscf::Core::DeliveryOrderItem", foreign_key: "dropoff_address_id"

      validates :latitude, :longitude, presence: true, if: :requires_coordinates?

      def coordinates
        [latitude.to_f, longitude.to_f] if latitude.present? && longitude.present?
      end

      def full_address
        %i[house_number woreda sub_city city].compact.join(", ")
      end

      private

      def requires_coordinates?
        # Determine when coordinates are required
        # For delivery addresses, they should always be required
        delivery_order_pickups.any? || delivery_order_item_pickups.any? || delivery_order_item_dropoffs.any?
      end
    end
  end
end
