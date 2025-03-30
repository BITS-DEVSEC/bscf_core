module Bscf::Core
  class DeliveryOrder < ApplicationRecord
    belongs_to :order
    belongs_to :delivery_address, class_name: 'Bscf::Core::Address'

    attribute :delivery_start_time, :datetime
    attribute :delivery_end_time, :datetime
    attribute :actual_delivery_time, :datetime

    validates :contact_phone, :status, :estimated_delivery_time, presence: true
    validate :end_time_after_start_time, if: -> { delivery_start_time.present? && delivery_end_time.present? }

    before_save :update_delivery_times
    before_save :calculate_actual_delivery_time

    enum :status, {
      pending: 0,
      in_transit: 1,
      delivered: 2,
      failed: 3,
      cancelled: 4
    }

    def delivery_duration
      return nil unless delivery_start_time && delivery_end_time
      ((delivery_end_time - delivery_start_time) / 1.hour).round(2)
    end

    private

    def update_delivery_times
      case status
      when 'in_transit'
        self.delivery_start_time = Time.current if delivery_start_time.nil?
      when 'delivered', 'failed'
        self.delivery_end_time = Time.current if delivery_end_time.nil?
      end
    end

    def calculate_actual_delivery_time
      self.actual_delivery_time = delivery_end_time if status == 'delivered'
    end

    def end_time_after_start_time
      return unless delivery_start_time && delivery_end_time
      if delivery_end_time <= delivery_start_time
        errors.add(:delivery_end_time, "must be after delivery start time")
      end
    end
  end
end
