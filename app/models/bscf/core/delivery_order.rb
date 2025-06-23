module Bscf
  module Core
    class DeliveryOrder < ApplicationRecord
      has_many :orders
      belongs_to :pickup_address, class_name: "Bscf::Core::Address"
      belongs_to :driver, class_name: "Bscf::Core::User", optional: true

      has_many :delivery_order_items, dependent: :destroy
      has_many :order_items, through: :delivery_order_items
      has_many :products, through: :delivery_order_items

      validates :driver_phone, :status, :estimated_delivery_time, presence: true
      validate :end_time_after_start_time, if: -> { delivery_start_time.present? && delivery_end_time.present? }

      before_save :update_delivery_times
      before_save :calculate_actual_delivery_time

      # after_save :sync_items_status, if: :saved_change_to_status?

      enum :status, {
        pending: 0,
        in_transit: 1,
        picked_up: 2,
        delivered: 3,
        received: 4,
        paid: 5,
        failed: 6,
        cancelled: 7
      }

      def delivery_duration
        return nil unless delivery_start_time && delivery_end_time
        ((delivery_end_time - delivery_start_time) / 1.hour).round(2)
      end

      def optimized_route
        return nil unless pickup_address&.coordinates.present?

        # Get all delivery order items with dropoff addresses
        items_with_dropoffs = delivery_order_items.includes(:dropoff_address)
                                                  .where.not(dropoff_address: nil)

        dropoff_addresses = items_with_dropoffs.map(&:dropoff_address).compact.uniq
        return nil if dropoff_addresses.empty?

        # Check if all dropoff addresses have coordinates
        return nil if dropoff_addresses.any? { |addr| addr.coordinates.blank? }

        # Call Gebeta Maps service
        gebeta_service = Bscf::Core::GebetaMapsService.new
        route_data = gebeta_service.optimize_route(pickup_address, dropoff_addresses)

        # Return nil if route_data is empty or doesn't have waypoints
        return nil if route_data.blank? || !route_data.key?("waypoints")

        # Cache the result if needed
        # Rails.cache.write("delivery_order_route_#{id}", route_data, expires_in: 1.hour)
        route_data
      end

      # Reorder delivery items based on optimized route or provided positions
      def reorder_items_by_route(positions = nil)
        if positions.is_a?(Hash)
          # Use provided positions
          positions.each do |item_id, position|
            if item = delivery_order_items.find_by(id: item_id)
              item.update(position: position)
            end
          end
          true
        else
          return false if positions && !positions.is_a?(Hash)

          # Use optimized route
          route_data = optimized_route

          return false unless route_data.present? && route_data["waypoints"].present?

          # Get the optimized order of waypoints
          waypoint_order = route_data["waypoints"].map { |wp| wp["waypoint_index"] }

          # Get all delivery order items with dropoff addresses
          items_with_dropoffs = delivery_order_items.includes(:dropoff_address)
                                                    .where.not(dropoff_address: nil)
                                                    .to_a

          # Skip if we don't have the same number of items as waypoints
          return false if items_with_dropoffs.size != waypoint_order.size

          # Reorder items based on waypoint order
          waypoint_order.each_with_index do |original_index, new_position|
            if item = items_with_dropoffs[original_index]
              item.update(position: new_position + 1)
            end
          end

          true
        end
      end

      # Add this method to the DeliveryOrder class
      def dropoff_addresses
        delivery_order_items.includes(:dropoff_address)
                            .where.not(dropoff_address: nil)
                            .map(&:dropoff_address)
                            .compact
                            .uniq
      end


      private

      def update_delivery_times
        case status
        when "in_transit"
          self.delivery_start_time = Time.current if delivery_start_time.nil?
        when "delivered", "failed"
          self.delivery_end_time = Time.current if delivery_end_time.nil?
        end
      end

      def calculate_actual_delivery_time
        self.actual_delivery_time = delivery_end_time if status == "delivered"
      end

      def end_time_after_start_time
        return unless delivery_start_time && delivery_end_time
        if delivery_end_time <= delivery_start_time
          errors.add(:delivery_end_time, "must be after delivery start time")
        end
      end

      def sync_items_status
        delivery_order_items.update_all(status: status)
      end
    end
  end
end
