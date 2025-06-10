require 'rails_helper'

module Bscf
  module Core
    RSpec.describe VirtualAccountTransaction, type: :model do
      attributes = [
        { amount: [ :presence, :numericality ] },
        { transaction_type: :presence },
        { entry_type: :presence },
        { status: :presence },
        { reference_number: [ :presence, :uniqueness ] },
        { account_id: :presence }
      ]

      include_examples("model_shared_spec", :virtual_account_transaction, attributes)

      describe 'validations' do
        it { should validate_numericality_of(:amount).is_greater_than(0) }
        
        it 'validates presence of paired_transaction for transfers' do
          transaction = build(:virtual_account_transaction, transaction_type: :transfer)
          expect(transaction.valid?).to be false
          expect(transaction.errors[:paired_transaction]).to include('must be present for transfers')
        end
      end

      describe 'enums' do
        it { should define_enum_for(:transaction_type).with_values(transfer: 0, deposit: 1, withdrawal: 2, fee: 3, adjustment: 4) }
        it { should define_enum_for(:entry_type).with_values(debit: 0, credit: 1) }
        it { should define_enum_for(:status).with_values(pending: 0, completed: 1, failed: 2, cancelled: 3) }
      end

      describe '#generate_reference_number' do
        let(:transaction) { build(:virtual_account_transaction, reference_number: nil) }

        it 'generates reference number before validation on create' do
          transaction.valid?
          expect(transaction.reference_number).to be_present
          expect(transaction.reference_number).to match(/\ATXN\d{14}[0-9a-f]{6}\z/)
        end

        it 'does not override existing reference number' do
          existing_ref = 'TXN20230101123456abc123'
          transaction.reference_number = existing_ref
          transaction.valid?
          expect(transaction.reference_number).to eq(existing_ref)
        end
      end

      describe 'transaction processing' do
        let(:debit_account) { create(:virtual_account, balance: 1000.00, status: :active) }
        let(:credit_account) { create(:virtual_account, balance: 500.00, status: :active) }
        let(:system_account) { create(:virtual_account, balance: 1000.00, status: :active) }
        
        context 'when processing transfer' do
          let(:debit_transaction) do
            create(:paired_transaction,
                  transaction_type: :transfer,
                  entry_type: :debit,
                  account: debit_account,
                  paired_account: credit_account,
                  amount: 300.00,
                  is_credit: false)
          end

          it 'updates account balances on successful transfer' do
            expect(debit_transaction.process!).to be true

            expect(debit_account.reload.balance.round(2)).to eq(700.00)
            expect(credit_account.reload.balance.round(2)).to eq(800.00)
            expect(debit_transaction.reload.status).to eq('completed')
            expect(debit_transaction.paired_transaction.reload.status).to eq('completed')
          end

          it 'validates sufficient balance' do
            transaction = build(:paired_transaction,
                                transaction_type: :transfer,
                                entry_type: :debit,
                                account: debit_account,
                                paired_account: credit_account,
                                amount: 2000.00,
                                is_credit: false)
                                    
            expect(transaction.valid?).to be false
            expect(transaction.errors[:account]).to include('insufficient balance')
          end

          it 'validates account status' do
            debit_account.update!(status: :suspended)
            transaction = build(:paired_transaction,
                                transaction_type: :transfer,
                                entry_type: :debit,
                                account: debit_account,
                                paired_account: credit_account,
                                amount: 300.00,
                                is_credit: false)
                                    
            expect(transaction.valid?).to be false
            expect(transaction.errors[:account]).to include('must be active')
          end
        end

        context 'when processing deposit' do
          let(:debit_transaction) do
            create(:paired_transaction,
                  transaction_type: :deposit,
                  entry_type: :debit,
                  account: system_account,
                  paired_account: credit_account,
                  amount: 300.00,
                  is_credit: false)
          end

          it 'updates recipient account balance' do
            expect(debit_transaction.process!).to be true

            expect(credit_account.reload.balance.to_f.round(2)).to eq(800.00)
            expect(debit_transaction.paired_transaction.reload.status).to eq('completed')
          end

          it 'validates recipient account status' do
            credit_account.update!(status: :suspended)
            transaction = build(:paired_transaction,
                                transaction_type: :deposit,
                                entry_type: :credit,
                                account: credit_account,
                                paired_account: system_account,
                                amount: 300.00,
                                is_credit: true)
                                      
            expect(transaction.valid?).to be false
            expect(transaction.errors[:account]).to include('must be active')
          end
        end

        context 'when processing withdrawal' do
          let(:debit_transaction) do
            create(:paired_transaction,
                  transaction_type: :withdrawal,
                  entry_type: :debit,
                  account: debit_account,
                  paired_account: system_account,
                  amount: 300.00,
                  is_credit: false)
          end

          it 'updates source account balance' do
            expect(debit_transaction.process!).to be true

            expect(debit_account.reload.balance.round(2)).to eq(700.00)
            expect(debit_transaction.reload.status).to eq('completed')
          end

          it 'validates source account status' do
            debit_account.update!(status: :suspended)
            transaction = build(:paired_transaction,
                                transaction_type: :withdrawal,
                                entry_type: :debit,
                                account: debit_account,
                                paired_account: system_account,
                                amount: 300.00,
                                is_credit: false)
                                    
            expect(transaction.valid?).to be false
            expect(transaction.errors[:account]).to include('must be active')
          end
        end
      end

      describe '#cancel!' do
        it 'cancels pending transaction' do
          debit_account = create(:virtual_account, balance: 1000.00, status: :active)
          credit_account = create(:virtual_account, balance: 500.00, status: :active)
          
          debit_transaction = create(:paired_transaction,
                                    transaction_type: :transfer,
                                    entry_type: :debit,
                                    account: debit_account,
                                    paired_account: credit_account,
                                    amount: 300.00,
                                    is_credit: false)
          
          expect(debit_transaction.cancel!).to be true
          expect(debit_transaction.status).to eq('cancelled')
        end

        it 'cannot cancel completed transaction' do
          debit_account = create(:virtual_account, balance: 1000.00, status: :active)
          credit_account = create(:virtual_account, balance: 500.00, status: :active)
          
          debit_transaction = create(:paired_transaction,
                                    transaction_type: :transfer,
                                    entry_type: :debit,
                                    account: debit_account,
                                    paired_account: credit_account,
                                    amount: 300.00,
                                    status: :completed,
                                    is_credit: false)
          
          expect(debit_transaction.cancel!).to be false
        end
      end
    end
  end
end
