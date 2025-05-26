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
        let(:virtual_account) { build(:virtual_account) }

        it 'generates account number on create' do
          expect(virtual_account.account_number).to be_nil
          virtual_account.save
          expect(virtual_account.account_number).to be_present
          expect(virtual_account.account_number).to match(/\ABR001SAVINGSREGULAR\d{6}\z/)
        end

        it 'maintains existing account number' do
          existing_number = 'BR001SAVINGSREGULAR000001'
          virtual_account.account_number = existing_number
          virtual_account.save
          expect(virtual_account.account_number).to eq(existing_number)
        end

        it 'increments sequence number' do
          first_account = create(:virtual_account)
          second_account = create(:virtual_account)

          first_seq = first_account.account_number[-6..-1].to_i
          second_seq = second_account.account_number[-6..-1].to_i

          expect(second_seq).to eq(first_seq + 1)
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