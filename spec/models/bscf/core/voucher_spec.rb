require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Voucher, type: :model do
      attributes = [
        { full_name: :presence },
        { phone_number: :presence },
        { amount: [ :presence, { numericality: [ [ "is_greater_than", 0 ] ] } ] },
        { code: [ :presence, :uniqueness ] },
        { issued_by: :belong_to }
      ]

      include_examples "model_shared_spec", :voucher, attributes

      describe 'state management' do
        let(:voucher) { create(:voucher) }
        let(:virtual_account) { instance_double(VirtualAccount) }

        before do
          allow(voucher.issued_by).to receive(:virtual_account).and_return(virtual_account)
          allow(virtual_account).to receive(:available_balance).and_return(1000.0)
          allow(virtual_account).to receive(:lock_amount!).and_return(true)
          allow(virtual_account).to receive(:unlock_amount!).and_return(true)
          allow(virtual_account).to receive(:transfer_to!).and_return(true)
        end

        describe 'activation' do
          it 'activates with sufficient balance' do
            voucher.send(:lock_issuer_amount)
            expect(voucher).to be_active
          end

          it 'fails activation with insufficient balance' do
            allow(virtual_account).to receive(:available_balance).and_return(0)
            voucher.send(:lock_issuer_amount)
            expect(voucher.errors[:amount]).to include("exceeds available balance")
          end
        end

        describe 'redemption' do
          let(:recipient_account) { create(:virtual_account) }
          let(:active_voucher) { create(:voucher, :active) }
          let(:transaction) { instance_double(VirtualAccountTransaction) }

          before do
            allow(VirtualAccountTransaction).to receive(:new).and_return(transaction)
            allow(transaction).to receive(:process!).and_return(true)
            allow(active_voucher.issued_by.virtual_account).to receive(:unlock_amount!).and_return(true)
          end

          it 'successfully redeems active voucher' do
            expect(active_voucher.redeem!(recipient_account)).to be true
            expect(active_voucher).to be_redeemed
            expect(VirtualAccountTransaction).to have_received(:new).with(
              from_account: active_voucher.issued_by.virtual_account,
              to_account: recipient_account,
              amount: active_voucher.amount,
              transaction_type: :transfer
            )
          end

          it 'handles transaction failure' do
            allow(transaction).to receive(:process!).and_return(false)
            expect(active_voucher.redeem!(recipient_account)).to be false
            expect(active_voucher.errors[:base]).to include("Voucher redemption failed due to transaction processing error.")
          end

          it 'handles unlock failure after successful transfer' do
            allow(active_voucher.issued_by.virtual_account).to receive(:unlock_amount!).and_return(false)
            expect(active_voucher.redeem!(recipient_account)).to be false
            expect(active_voucher.errors[:base]).to include("Failed to unlock amount from issuer after successful transfer.")
          end
        end

        describe 'state transitions' do
          let(:active_voucher) { create(:voucher, :active) }

          it 'handles return transition' do
            expect(active_voucher.return!).to be true
            expect(active_voucher).to be_returned
          end

          it 'handles cancel transition' do
            expect(active_voucher.cancel!).to be true
            expect(active_voucher).to be_cancelled
          end

          it 'validates state predicates' do
            expect(active_voucher.can_return?).to be true
            expect(active_voucher.can_cancel?).to be true

            active_voucher.update!(status: :redeemed)
            expect(active_voucher.can_return?).to be false
            expect(active_voucher.can_cancel?).to be false
          end
        end
      end
    end
  end
end
