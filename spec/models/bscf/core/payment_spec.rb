require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Payment, type: :model do
      attributes = [
        { invoice: :belong_to },
        { virtual_account_transaction: [ { belong_to: [ [ :optional, nil ] ] } ] },
        { amount: [:presence, :numericality] },
        { payment_method: :presence },
        { status: :presence },
        { reference_number: [:presence, :uniqueness] }
      ]
      
      include_examples("model_shared_spec", :payment, attributes)
      
      describe 'validations' do
        it { should validate_numericality_of(:amount).is_greater_than(0) }
      end
      
      describe 'enums' do
        it { should define_enum_for(:payment_method).with_values(cash: 0, virtual_account: 1) }
        it { should define_enum_for(:status).with_values(pending: 0, completed: 1, failed: 2, refunded: 3) }
      end
      
      describe '#generate_reference_number' do
        let(:payment) { build(:payment, reference_number: nil) }
        
        it 'generates reference number before validation on create' do
          payment.valid?
          expect(payment.reference_number).to be_present
          expect(payment.reference_number).to match(/\APAY\d{14}[0-9a-f]{6}\z/)
        end
      end
      
      describe '#update_invoice_status' do
        let(:invoice) { create(:invoice, amount: 100, tax_amount: 10, discount_amount: 0, total_amount: 110, status: :issued) }
        
        context 'when payment covers full invoice amount' do
          it 'updates invoice status to paid' do
            create(:payment, invoice: invoice, amount: 110, status: :completed)
            expect(invoice.reload.status).to eq('paid')
          end
        end
        
        context 'when payment covers partial invoice amount' do
          it 'updates invoice status to partially_paid' do
            create(:payment, invoice: invoice, amount: 50, status: :completed)
            expect(invoice.reload.status).to eq('partially_paid')
          end
        end
      end
    end
  end
end