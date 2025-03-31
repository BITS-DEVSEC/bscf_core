module Bscf::Core
  class DeliveryOrderItem < ApplicationRecord
    belongs_to :delivery_order
    belongs_to :order_item
    belongs_to :product

    validates :quantity, :status, presence: true
    validate :quantity_not_exceeding_order_item
    validate :status_matches_delivery_order

    after_save :update_delivery_order_status
    before_save :sync_status_with_delivery_order

    enum :status, {
      pending: 0,
      in_transit: 1,
      delivered: 2,
      failed: 3,
      cancelled: 4
    }

    private

    def quantity_not_exceeding_order_item
      return unless quantity && order_item&.quantity
      if quantity > order_item.quantity
        errors.add(:quantity, "cannot exceed order item quantity (#{order_item.quantity.to_i})")
      end
    end

    def status_matches_delivery_order
      return unless delivery_order && status_changed?
      unless status.to_s == delivery_order.status
        errors.add(:status, "must match delivery order status")
      end
    end

    def sync_status_with_delivery_order
      self.status = delivery_order.status if delivery_order
    end

    def update_delivery_order_status
      return unless status_previously_changed?

      all_items_status = delivery_order.delivery_order_items.pluck(:status).uniq
      if all_items_status.size == 1
        delivery_order.update(status: all_items_status.first)
      end
    end
  end
end
