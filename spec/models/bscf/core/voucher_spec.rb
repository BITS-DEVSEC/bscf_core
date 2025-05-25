require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Voucher, type: :model do
      attributes = [
        { full_name: :presence },
        { phone_number: :presence },
        { amount: [ :presence, :numericality ] },
        { code: [ :presence, :uniqueness ] },
        { issued_by: :belong_to }
      ]

      include_examples("model_shared_spec", :voucher, attributes)

      describe 'callbacks' do
        describe '#generate_code' do
          let(:voucher) { build(:voucher) }

          it 'generates a code before validation' do
            expect(voucher.code).to be_nil
            voucher.valid?
            expect(voucher.code).to be_present
            expect(voucher.code).to match(/\A[0-9A-F]{16}\z/)
          end

          it 'does not regenerate existing code' do
            voucher.code = 'EXISTING123456789'
            voucher.valid?
            expect(voucher.code).to eq('EXISTING123456789')
          end
        end

        describe '#set_default_expiry' do
          it 'sets default expiry to 30 days from now' do
            voucher = create(:voucher)
            expect(voucher.expires_at).to be_within(1.second).of(30.days.from_now)
          end

          it 'respects custom expiry date' do
            custom_date = 15.days.from_now
            voucher = create(:voucher, expires_at: custom_date)
            expect(voucher.expires_at).to be_within(1.second).of(custom_date)
          end
        end
      end

      describe '#lock_issuer_amount' do
        context 'with sufficient balance' do
          let(:voucher) { build(:voucher, :with_sufficient_balance) }

          it 'locks the amount and activates the voucher' do
            expect(voucher.save).to be true
            expect(voucher).to be_active
            expect(voucher.issued_by.virtual_account.locked_amount).to eq(voucher.amount)
          end
        end

        context 'with insufficient balance' do
          let(:voucher) { build(:voucher) }

          it 'fails to create the voucher' do
            expect(voucher.save).to be false
            expect(voucher.errors[:amount]).to include('could not be locked')
          end
        end
      end

      describe '#redeem!' do
        let(:recipient_account) { create(:virtual_account, :with_balance) }

        context 'with active voucher' do
          let(:voucher) { create(:voucher, :active) }

          attributes = [
            { full_name: :presence },
            { phone_number: :presence },
            { amount: [ :presence, :numericality ] },
            { code: [ :presence, :uniqueness ] },
            { issued_by: :belong_to }
          ]
          
          it 'successfully transfers funds to recipient' do
            initial_balance = recipient_account.balance
            expect(voucher.redeem!(recipient_account)).to be true
            expect(voucher).to be_redeemed
            expect(recipient_account.reload.balance).to eq(initial_balance + voucher.amount)
          end
        end

        [:expired, :returned, :cancelled].each do |status|
          context "with #{status} voucher" do
            let(:voucher) { create(:voucher, status) }

            it 'fails to redeem' do
              expect(voucher.redeem!(recipient_account)).to be false
              expect(voucher).not_to be_redeemed
            end
          end
        end
      end

      describe '#return!' do
        context 'with redeemed voucher' do
          let(:voucher) { create(:voucher, :redeemed) }

          it 'successfully returns the voucher' do
            expect(voucher.return!).to be true
            expect(voucher).to be_returned
            expect(voucher.returned_at).to be_present
          end
        end

        [:expired, :returned, :cancelled].each do |status|
          context "with #{status} voucher" do
            let(:voucher) { create(:voucher, status) }

            it 'fails to return' do
              expect(voucher.return!).to be false
              expect(voucher).not_to be_returned
            end
          end
        end
      end

      describe '#cancel!' do
        context 'with active voucher' do
          let(:voucher) { create(:voucher, :active) }

          it 'successfully cancels the voucher' do
            expect(voucher.cancel!).to be true
            expect(voucher).to be_cancelled
            expect(voucher.returned_at).to be_present
          end
        end

        [:redeemed, :expired, :returned, :cancelled].each do |status|
          context "with #{status} voucher" do
            let(:voucher) { create(:voucher, status) }

            it 'fails to cancel' do
              expect(voucher.cancel!).to be false
              expect(voucher).not_to be_cancelled
            end
          end
        end
      end
    end
  end
end
