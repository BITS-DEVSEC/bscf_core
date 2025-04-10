require 'rails_helper'

module Bscf
  module Core
    RSpec.describe DeliveryOrder, type: :model do
      attributes = [
        { order: :belong_to },
        { pickup_address: :belong_to },
        { dropoff_address: :belong_to },
        { buyer_phone: :presence },
        { seller_phone: :presence },
        { driver_phone: :presence },
        { status: :presence },
        { estimated_delivery_time: :presence }
      ]
      include_examples("model_shared_spec", :delivery_order, attributes)

      describe 'status management' do
        it 'updates all delivery order items status when status changes' do
          delivery_order = create(:delivery_order, status: :pending)
          items = create_list(:delivery_order_item, 3, delivery_order: delivery_order)

          delivery_order.update(status: :in_transit)

          items.each do |item|
            item.reload
            expect(item.status).to eq('in_transit')
          end
        end
      end

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

        it 'validates end time is after start time' do
          delivery_order = create(:delivery_order, :in_transit)
          delivery_order.delivery_end_time = delivery_order.delivery_start_time - 1.hour

          expect(delivery_order).not_to be_valid
          expect(delivery_order.errors[:delivery_end_time]).to include("must be after delivery start time")
        end
      end
    end
  end
end
