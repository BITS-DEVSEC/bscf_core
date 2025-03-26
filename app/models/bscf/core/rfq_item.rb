module Bscf
  module Core
    class RfqItem < ApplicationRecord
      belongs_to :request_for_quotation
      belongs_to :product
      validates :quantity, presence: true
    end
  end
end
