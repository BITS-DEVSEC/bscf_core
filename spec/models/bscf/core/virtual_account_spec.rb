require 'rails_helper'

module Bscf
  module Core
    RSpec.describe VirtualAccount, type: :model do
      attributes = [
        { account_number: %i[presence uniqueness] },
        { cbs_account_number: %i[presence uniqueness] },
        { balance: [ :presence, :numericality ] },
        { interest_rate: [ :presence, :numericality ] },
        { interest_type: :presence },
        { branch_code: :presence },
        { product_scheme: [ :presence ] },
        { voucher_type: [ :presence ] },
        { status: :presence },
        { user: :belong_to },
        { locked_amount: [ :presence, :numericality ] }
      ]

      include_examples("model_shared_spec", :virtual_account, attributes)

      it { should validate_numericality_of(:balance).is_greater_than_or_equal_to(0) }
      it { should validate_numericality_of(:interest_rate).is_greater_than_or_equal_to(0) }
      it { should validate_numericality_of(:locked_amount).is_greater_than_or_equal_to(0) }
      it { should validate_inclusion_of(:product_scheme).in_array(VirtualAccount::PRODUCT_SCHEMES) }
      it { should validate_inclusion_of(:voucher_type).in_array(VirtualAccount::VOUCHER_TYPES) }

      describe 'scopes' do
        let!(:active_account) { create(:virtual_account, :active_status) }
        let!(:pending_account) { create(:virtual_account) }
        let!(:savings_account) { create(:virtual_account) }
        let!(:current_account) { create(:virtual_account, :current_account) }
        let!(:loan_account) { create(:virtual_account, :loan_account) }

        it 'filters active accounts' do
          expect(described_class.active_accounts).to include(active_account)
          expect(described_class.active_accounts).not_to include(pending_account)
        end

        it 'filters by branch' do
          expect(described_class.by_branch('BR001')).to include(active_account)
        end

        it 'filters by product scheme' do
          expect(described_class.by_product('SAVINGS')).to include(savings_account)
          expect(described_class.by_product('SAVINGS')).not_to include(current_account)
          expect(described_class.by_product('CURRENT')).to include(current_account)
          expect(described_class.by_product('LOAN')).to include(loan_account)
        end
      end

      describe '#generate_account_number' do
        before { VirtualAccount.delete_all }

        it 'generates unique account numbers' do
          account1 = create(:virtual_account)
          account2 = create(:virtual_account)
          account3 = create(:virtual_account)

          expect(account1.account_number).not_to eq(account2.account_number)
          expect(account2.account_number).not_to eq(account3.account_number)
          expect(account1.account_number).not_to eq(account3.account_number)
        end

        it 'generates sequential account numbers' do
          account1 = create(:virtual_account)
          account2 = create(:virtual_account)
          account3 = create(:virtual_account)

          seq1 = account1.account_number[-6..-1].to_i
          seq2 = account2.account_number[-6..-1].to_i
          seq3 = account3.account_number[-6..-1].to_i

          expect(seq2).to eq(seq1 + 1)
          expect(seq3).to eq(seq2 + 1)
        end

        it 'generates account numbers with correct 11-digit format (all numbers)' do
          account = create(:virtual_account, branch_code: '001', product_scheme: 'SAVINGS', voucher_type: 'REGULAR')

          expect(account.account_number).to match(/\A\d{11}\z/)
          expect(account.account_number.length).to eq(11)

          expect(account.account_number).to match(/\A[0-9]+\z/)
        end

        it 'formats different account types correctly' do
          savings_account = create(:virtual_account, branch_code: '001', product_scheme: 'SAVINGS', voucher_type: 'REGULAR')
          current_account = create(:virtual_account, branch_code: '002', product_scheme: 'CURRENT', voucher_type: 'SPECIAL')
          loan_account = create(:virtual_account, branch_code: '003', product_scheme: 'LOAN', voucher_type: 'TEMPORARY')

          [ savings_account, current_account, loan_account ].each do |account|
            expect(account.account_number).to match(/\A\d{11}\z/)
            expect(account.account_number.length).to eq(11)
          end

          expect(savings_account.account_number[0..4]).to eq('00111')
          expect(current_account.account_number[0..4]).to eq('00222')
          expect(loan_account.account_number[0..4]).to eq('00333')
        end

        it 'maintains existing account number if already set' do
          existing_number = '12345678901'
          account = build(:virtual_account, account_number: existing_number)
          account.save

          expect(account.account_number).to eq(existing_number)
        end
      end

      describe 'interest types' do
        it 'supports simple interest' do
          account = build(:virtual_account)
          expect(account.interest_type).to eq('simple')
        end

        it 'supports compound interest' do
          account = build(:virtual_account, :compound_interest)
          expect(account.interest_type).to eq('compound')
        end
      end

      describe 'account types' do
        it 'creates savings account by default' do
          account = create(:virtual_account)
          expect(account.product_scheme).to eq('SAVINGS')
          expect(account.interest_rate).to eq(2.5)
        end

        it 'creates current account' do
          account = create(:virtual_account, :current_account)
          expect(account.product_scheme).to eq('CURRENT')
          expect(account.interest_rate).to eq(0.0)
        end

        it 'creates loan account' do
          account = create(:virtual_account, :loan_account)
          expect(account.product_scheme).to eq('LOAN')
          expect(account.interest_rate).to eq(12.5)
        end
      end

      describe '#available_balance' do
        let(:virtual_account) { create(:virtual_account, balance: 1000.0, locked_amount: 300.0) }

        it 'returns balance minus locked amount' do
          expect(virtual_account.available_balance).to eq(700.0)
        end
      end

      describe '#lock_amount!' do
        let(:virtual_account) { create(:virtual_account, balance: 1000.0, locked_amount: 0.0) }

        context 'when amount is valid' do
          it 'increases locked_amount' do
            expect { virtual_account.lock_amount!(500.0) }.to change { virtual_account.locked_amount }.by(500.0)
          end
        end

        context 'when amount is greater than available balance' do
          it 'returns false' do
            expect(virtual_account.lock_amount!(1500.0)).to be false
          end
        end

        context 'when amount is negative' do
          it 'returns false' do
            expect(virtual_account.lock_amount!(-100.0)).to be false
          end
        end
      end

      describe '#unlock_amount!' do
        let(:virtual_account) { create(:virtual_account, balance: 1000.0, locked_amount: 300.0) }

        context 'when amount is valid' do
          it 'decreases locked_amount' do
            expect { virtual_account.unlock_amount!(100.0) }.to change { virtual_account.locked_amount }.by(-100.0)
          end
        end

        context 'when amount is greater than locked amount' do
          it 'returns false' do
            expect(virtual_account.unlock_amount!(500.0)).to be false
          end
        end

        context 'when amount is negative' do
          it 'returns false' do
            expect(virtual_account.unlock_amount!(-100.0)).to be false
          end
        end
      end

      describe 'available_balance_sufficient validation' do
        let(:virtual_account) { build(:virtual_account, balance: 1000.0) }

        it 'is valid when locked_amount is less than balance' do
          virtual_account.locked_amount = 500.0
          expect(virtual_account).to be_valid
        end

        it 'is valid when locked_amount equals balance' do
          virtual_account.locked_amount = 1000.0
          expect(virtual_account).to be_valid
        end

        it 'is invalid when locked_amount exceeds balance' do
          virtual_account.locked_amount = 1500.0
          expect(virtual_account).not_to be_valid
          expect(virtual_account.errors[:locked_amount]).to include('cannot exceed balance')
        end
      end
    end
  end
end
