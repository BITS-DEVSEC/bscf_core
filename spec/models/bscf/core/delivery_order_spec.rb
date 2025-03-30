require 'rails_helper'

module Bscf
  module Core
    RSpec.describe DeliveryOrder, type: :model do
      attributes = [
        { order: :belong_to },
        { delivery_address: :belong_to },
        { contact_phone: :presence },
        { status: :presence },
        { estimated_delivery_time: :presence }
      ]
      include_examples("model_shared_spec", :delivery_order, attributes)

      describe 'delivery times' do
        it 'sets delivery start time when status changes to in_transit' do
          delivery_order = create(:delivery_order)
          delivery_order.update(status: :in_transit)
          expect(delivery_order.delivery_start_time).to be_present
        end

        it 'sets delivery end time when status changes to delivered' do
          delivery_order = create(:delivery_order, :in_transit)
          delivery_order.update(status: :delivered)
          expect(delivery_order.delivery_end_time).to be_present
        end

        it 'sets delivery end time when status changes to failed' do
          delivery_order = create(:delivery_order, :in_transit)
          delivery_order.update(status: :failed)
          expect(delivery_order.delivery_end_time).to be_present
        end

        it 'calculates actual delivery time when delivered' do
          delivery_order = create(:delivery_order, :in_transit)
          delivery_order.update(status: :delivered)
          expect(delivery_order.actual_delivery_time).to eq(delivery_order.delivery_end_time)
        end

        it 'does not set actual delivery time when failed' do
          delivery_order = create(:delivery_order, :in_transit)
          delivery_order.update(status: :failed)
          expect(delivery_order.actual_delivery_time).to be_nil
        end
      end

      describe '#delivery_duration' do
        it 'returns nil when times are not set' do
          delivery_order = create(:delivery_order)
          expect(delivery_order.delivery_duration).to be_nil
        end

        it 'calculates duration in hours' do
          start_time = Time.current
          end_time = 2.5.hours.from_now
          delivery_order = create(:delivery_order, delivery_start_time: start_time, delivery_end_time: end_time)
          expect(delivery_order.delivery_duration).to eq(2.5)
        end
      end

      describe 'validations' do
        it 'validates end time is after start time' do
          delivery_order = build(:delivery_order, 
            delivery_start_time: Time.current,
            delivery_end_time: 1.hour.ago
          )
          expect(delivery_order).not_to be_valid
          expect(delivery_order.errors[:delivery_end_time]).to include("must be after delivery start time")
        end
      end
    end
  end
end
