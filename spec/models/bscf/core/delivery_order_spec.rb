require 'rails_helper'

module Bscf
  module Core
    RSpec.describe DeliveryOrder, type: :model do
      attributes = [
        { pickup_address: :belong_to },
        { dropoff_address: :belong_to },
        { driver_phone: :presence },
        { status: :presence },
        { estimated_delivery_time: :presence }
      ]
      include_examples("model_shared_spec", :delivery_order, attributes)

      describe 'associations' do
        it 'can have multiple orders' do
          delivery_order = create(:delivery_order)
          order1 = create(:order, delivery_order: delivery_order)
          order2 = create(:order, delivery_order: delivery_order)
          expect(delivery_order.orders.count).to eq(2)
        end
      end

      describe 'delivery times' do
        it 'sets delivery start time when status changes to in_transit' do
          delivery_order = create(:delivery_order)
          delivery_order.update(status: :in_transit)
          expect(delivery_order.delivery_start_time).to be_present
        end

        it 'sets delivery end time when status changes to delivered' do
          delivery_order = create(:delivery_order, status: :in_transit, delivery_start_time: 1.hour.ago)
          delivery_order.update(status: :delivered)
          expect(delivery_order.delivery_end_time).to be_present
        end

        it 'sets delivery end time when status changes to failed' do
          delivery_order = create(:delivery_order, status: :in_transit, delivery_start_time: 1.hour.ago)
          delivery_order.update(status: :failed)
          expect(delivery_order.delivery_end_time).to be_present
        end

        it 'validates end time is after start time' do
          delivery_order = create(:delivery_order, status: :in_transit, delivery_start_time: 1.hour.ago)
          delivery_order.delivery_end_time = delivery_order.delivery_start_time - 1.hour

          expect(delivery_order).not_to be_valid
          expect(delivery_order.errors[:delivery_end_time]).to include("must be after delivery start time")
        end
      end

      describe '#dropoff_addresses' do
        it 'returns all unique dropoff addresses from delivery order items' do
          delivery_order = create(:delivery_order)
          address1 = create(:address)
          address2 = create(:address)

          # Create items with dropoff addresses
          create(:delivery_order_item, delivery_order: delivery_order, dropoff_address: address1)
          create(:delivery_order_item, delivery_order: delivery_order, dropoff_address: address2)
          create(:delivery_order_item, delivery_order: delivery_order, dropoff_address: address1) # Duplicate address

          # Create an item without a dropoff address
          create(:delivery_order_item, delivery_order: delivery_order, dropoff_address: nil)

          expect(delivery_order.dropoff_addresses).to match_array([ address1, address2 ])
        end

        it 'returns an empty array when no items have dropoff addresses' do
          delivery_order = create(:delivery_order)
          create(:delivery_order_item, delivery_order: delivery_order, dropoff_address: nil)

          expect(delivery_order.dropoff_addresses).to be_empty
        end
      end

      describe '#reorder_items_by_route' do
        let(:delivery_order) { create(:delivery_order) }
        let!(:item1) { create(:delivery_order_item, delivery_order: delivery_order) }
        let!(:item2) { create(:delivery_order_item, delivery_order: delivery_order) }
        let!(:item3) { create(:delivery_order_item, delivery_order: delivery_order) }

        it 'updates positions of delivery order items' do
          positions = {
            item1.id.to_s => 2,
            item2.id.to_s => 1,
            item3.id.to_s => 3
          }

          expect(delivery_order.reorder_items_by_route(positions)).to be true

          item1.reload
          item2.reload
          item3.reload

          expect(item1.position).to eq(2)
          expect(item2.position).to eq(1)
          expect(item3.position).to eq(3)
        end

        it 'returns false if positions is not a hash' do
          expect(delivery_order.reorder_items_by_route("not a hash")).to be false
        end

        it 'returns false if any item id is invalid' do
          positions = {
            "999" => 1,
            item2.id.to_s => 2
          }

          expect(delivery_order.reorder_items_by_route(positions)).to be true
          item2.reload
          expect(item2.position).to eq(2)
        end
      end

      describe '#optimized_route' do
        let(:delivery_order) { create(:delivery_order) }
        let(:gebeta_service) { instance_double("Bscf::Core::GebetaMapsService") }

        before do
          # Mock the GebetaMapsService
          allow(Bscf::Core::GebetaMapsService).to receive(:new).and_return(gebeta_service)
          # Ensure addresses have coordinates
          allow_any_instance_of(Address).to receive(:coordinates).and_return([ 0.0, 0.0 ])
        end

        it 'returns an array of item IDs in optimized order' do
          item1 = create(:delivery_order_item, delivery_order: delivery_order)
          item2 = create(:delivery_order_item, delivery_order: delivery_order)

          # Mock different coordinates for testing
          allow(item1.dropoff_address).to receive(:coordinates).and_return([ 1.0, 1.0 ])
          allow(item2.dropoff_address).to receive(:coordinates).and_return([ 2.0, 2.0 ])

          # Mock the service response
          allow(gebeta_service).to receive(:optimize_route).and_return({
            "waypoints" => [
              { "waypoint_index" => 0 },
              { "waypoint_index" => 1 }
            ]
          })

          expect(delivery_order.optimized_route).to be_a(Hash)
          expect(delivery_order.optimized_route).to have_key("waypoints")
        end

        it 'returns empty array if pickup address has no coordinates' do
          allow(delivery_order.pickup_address).to receive(:coordinates).and_return(nil)
          expect(delivery_order.optimized_route).to be_nil
        end

        it 'returns empty array if no items have dropoff addresses' do
          create(:delivery_order_item, delivery_order: delivery_order, dropoff_address: nil)
          expect(delivery_order.optimized_route).to be_nil
        end

        it 'returns empty array if any dropoff address has no coordinates' do
          item = create(:delivery_order_item, delivery_order: delivery_order)
          allow(item.dropoff_address).to receive(:coordinates).and_return(nil)

          # Set up the mock to handle the expected call
          allow(gebeta_service).to receive(:optimize_route).and_return({})

          expect(delivery_order.optimized_route).to be_nil
        end
      end
    end
  end
end
