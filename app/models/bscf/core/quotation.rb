module Bscf
  module Core
    class Quotation < ApplicationRecord
      belongs_to :request_for_quotation
      belongs_to :business

      validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :delivery_date, presence: true
      validates :valid_until, presence: true
      validates :status, presence: true

      enum :status, {
        draft: 0,
        submitted: 1,
        accepted: 2,
        rejected: 3,
        expired: 4
      }

      scope :active, -> { where.not(status: [ :rejected, :expired ]) }
      scope :by_business, ->(business_id) { where(business_id: business_id) }
      scope :by_rfq, ->(rfq_id) { where(request_for_quotation_id: rfq_id) }
    end
  end
end
