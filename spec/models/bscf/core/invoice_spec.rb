require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Invoice, type: :model do
      attributes = [
        { order: :belong_to },
        { invoice_number: [ :presence, :uniqueness ] },
        { amount: [ :presence, :numericality ] },
        { tax_amount: [ :presence, :numericality ] },
        { discount_amount: [ :presence, :numericality ] },
        { total_amount: [ :presence, :numericality ] },
        { status: :presence }
      ]

      include_examples("model_shared_spec", :invoice, attributes)

      describe '#generate_invoice_number' do
        let(:invoice) { build(:invoice, invoice_number: nil) }

        it 'generates invoice number before validation on create' do
          invoice.valid?
          expect(invoice.invoice_number).to be_present
          expect(invoice.invoice_number).to match(/\AINV\d{14}[0-9a-f]{6}\z/)
        end

        it 'does not override existing invoice number' do
          existing_number = 'INV20230101123456abc123'
          invoice.invoice_number = existing_number
          invoice.valid?
          expect(invoice.invoice_number).to eq(existing_number)
        end
      end

      describe 'validations' do
        it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
        it { should validate_numericality_of(:tax_amount).is_greater_than_or_equal_to(0) }
        it { should validate_numericality_of(:discount_amount).is_greater_than_or_equal_to(0) }
        it { should validate_numericality_of(:total_amount).is_greater_than_or_equal_to(0) }
      end

      describe 'enums' do
        it { should define_enum_for(:status).with_values(draft: 0, issued: 1, paid: 2, partially_paid: 3, overdue: 4, cancelled: 5) }
      end
    end
  end
end
