require 'rails_helper'

module Bscf
  module Core
    RSpec.describe VirtualAccountTransaction, type: :model do
      attributes = [
        { amount: [ :presence, :numericality ] },
        { transaction_type: :presence },
        { status: :presence },
        { reference_number: [ :presence, :uniqueness ] }
      ]

      include_examples("model_shared_spec", :virtual_account_transaction, attributes)

      describe 'validations' do
        it { should validate_numericality_of(:amount).is_greater_than(0) }
      end

      describe 'enums' do
        it { should define_enum_for(:transaction_type).with_values(transfer: 0, deposit: 1, withdrawal: 2) }
        it { should define_enum_for(:status).with_values(pending: 0, completed: 1, failed: 2, cancelled: 3) }
      end

      describe '#generate_reference_number' do
        let(:transaction) { build(:virtual_account_transaction) }

        it 'generates reference number before validation on create' do
          transaction.save
          expect(transaction.reference_number).to be_present
          expect(transaction.reference_number).to match(/\ATXN\d{14}[0-9a-f]{6}\z/)
        end

        it 'does not override existing reference number' do
          existing_ref = 'TXN20230101123456abc123'
          transaction.reference_number = existing_ref
          transaction.save
          expect(transaction.reference_number).to eq(existing_ref)
        end
      end

      describe 'transaction processing' do
        let(:from_account) { create(:virtual_account, balance: 1000.00, status: :active) }
        let(:to_account) { create(:virtual_account, balance: 500.00, status: :active) }
        let(:transaction) do
          build(:virtual_account_transaction,
                from_account: from_account,
                to_account: to_account,
                amount: 300.00)
        end

        context 'when processing transfer' do
          it 'updates account balances on successful transfer' do
            expect(transaction.save).to be true
            expect(transaction.process!).to be true

            expect(from_account.reload.balance.round(2)).to eq(700.00)
            expect(to_account.reload.balance.round(2)).to eq(800.00)
            expect(transaction.reload.status).to eq('completed')
          end

          it 'validates sufficient balance' do
            transaction.amount = 2000.00
            expect(transaction.save).to be false
            expect(transaction.errors[:from_account]).to include('insufficient balance')
          end

          it 'validates account status' do
            from_account.update!(status: :suspended)
            expect(transaction.save).to be false
            expect(transaction.errors[:from_account]).to include('must be active')
          end
        end

        context 'when processing deposit' do
          let(:transaction) do
            build(:virtual_account_transaction, :deposit,
                  to_account: to_account,
                  amount: 300.00)
          end

          it 'updates recipient account balance' do
            expect(transaction.save).to be true
            expect(transaction.process!).to be true

            expect(to_account.reload.balance.round(2)).to eq(800.00)
            expect(transaction.reload.status).to eq('completed')
          end

          it 'validates recipient account status' do
            to_account.update!(status: :suspended)
            expect(transaction.save).to be false
            expect(transaction.errors[:to_account]).to include('must be active')
          end
        end

        context 'when processing withdrawal' do
          let(:transaction) do
            build(:virtual_account_transaction, :withdrawal,
                  from_account: from_account,
                  amount: 300.00)
          end

          it 'updates source account balance' do
            expect(transaction.save).to be true
            expect(transaction.process!).to be true

            expect(from_account.reload.balance.round(2)).to eq(700.00)
            expect(transaction.reload.status).to eq('completed')
          end

          it 'validates source account status' do
            from_account.update!(status: :suspended)
            expect(transaction.save).to be false
            expect(transaction.errors[:from_account]).to include('must be active')
          end
        end
      end

      describe '#cancel!' do
        it 'cancels pending transaction' do
          transaction = create(:virtual_account_transaction)
          expect(transaction.cancel!).to be true
          expect(transaction.status).to eq('cancelled')
        end

        it 'cannot cancel completed transaction' do
          transaction = create(:virtual_account_transaction, :completed)
          expect(transaction.cancel!).to be false
        end
      end
    end
  end
end
