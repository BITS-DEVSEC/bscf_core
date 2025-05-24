module Bscf
  module Core
    class Order < ApplicationRecord
      belongs_to :ordered_by, class_name: "Bscf::Core::User", optional: true
      belongs_to :ordered_to, class_name: "Bscf::Core::User", optional: true
      belongs_to :quotation, optional: true
      belongs_to :delivery_order, optional: true 
      has_many :order_items, dependent: :destroy
      validates :order_type, :status, presence: true

      enum :order_type, {
        order_from_quote: 0,
        direct_order: 1
      }

      enum :status, {
        draft: 0,
        submitted: 1,
        accepted: 3,
        delivering: 4,
        canceled: 5
      }
    end
  end
end
