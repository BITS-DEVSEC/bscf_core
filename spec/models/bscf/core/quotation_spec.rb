require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Quotation, type: :model do
      attributes = [
        { price: [ :presence, :numericality ] },
        { delivery_date: :presence },
        { valid_until: :presence },
        { status: :presence },
        { request_for_quotation: :belong_to },
        { business: :belong_to },
        { quotation_items: :have_many },
        { orders: :have_many },
        { products: :have_many}
      ]

      include_examples("model_shared_spec", :quotation, attributes)

      describe 'validations' do
        it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
      end

      describe 'enums' do
        it { should define_enum_for(:status).with_values(draft: 0, submitted: 1, accepted: 2, rejected: 3, expired: 4) }
      end

      describe 'scopes' do
        let!(:draft_quotation) { create(:quotation) }
        let!(:submitted_quotation) { create(:quotation, :submitted) }
        let!(:rejected_quotation) { create(:quotation, :rejected) }
        let!(:expired_quotation) { create(:quotation, :expired) }

        it 'filters active quotations' do
          expect(described_class.active).to include(draft_quotation, submitted_quotation)
          expect(described_class.active).not_to include(rejected_quotation, expired_quotation)
        end
      end
    end
  end
end
