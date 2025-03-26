module Bscf
  module Core
    class Business < ApplicationRecord
      belongs_to :user

      validates :business_name, presence: true
      validates :tin_number, presence: true, uniqueness: { case_sensitive: false }
      validates :business_type, presence: true
      validates :verification_status, presence: true

      enum :business_type, { retailer: 0, wholesaler: 1 }
      enum :verification_status, { pending: 0, approved: 1, rejected: 2 }
    end
  end
end
