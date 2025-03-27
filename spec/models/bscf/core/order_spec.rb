require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Order, type: :model do
      attributes = [
        { quotation: [ { belong_to: [ [ :optional, nil ] ] } ] },
        { ordered_by: [ { belong_to: [ [ :optional, nil ] ] } ] },
        { ordered_to: [ { belong_to: [ [ :optional, nil ] ] } ] },
        { order_type: :presence },
        { status: :presence }
      ]
      include_examples("model_shared_spec", :order, attributes)
    end
  end
end
