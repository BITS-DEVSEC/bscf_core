module Bscf::Core
  class DeliveryOrder < ApplicationRecord
    belongs_to :order
    belongs_to :pickup_address, class_name: "Bscf::Core::Address"
    belongs_to :dropoff_address, class_name: "Bscf::Core::Address"
    belongs_to :driver, class_name: "Bscf::Core::User", optional: true

    has_many :delivery_order_items, dependent: :destroy
    has_many :order_items, through: :delivery_order_items
    has_many :products, through: :delivery_order_items

    validates :buyer_phone, :seller_phone, :driver_phone,
              :status, :estimated_delivery_time, presence: true
    validate :end_time_after_start_time, if: -> { delivery_start_time.present? && delivery_end_time.present? }

    before_save :update_delivery_times
    before_save :calculate_actual_delivery_time
    after_save :sync_items_status, if: :saved_change_to_status?

    enum :status, {
      pending: 0,
      in_transit: 1,
      picked_up: 2,
      delivered: 3,
      failed: 4,
      cancelled: 5
    }

    def delivery_duration
      return nil unless delivery_start_time && delivery_end_time
      ((delivery_end_time - delivery_start_time) / 1.hour).round(2)
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
