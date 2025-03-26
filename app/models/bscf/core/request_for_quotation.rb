module Bscf
  module Core
    class RequestForQuotation < ApplicationRecord
      belongs_to :user
      validates :status, presence: true

      enum :status, { draft: 0, submitted: 1, awaiting_confirmation: 2, confirmed: 3, converted: 4 }
    end
  end
end
