require 'rails_helper'

module Bscf
  module Core
    RSpec.describe RequestForQuotation, type: :model do
      attributes = [
        { user: :belong_to },
        { status: :presence }
      ]
      include_examples("model_shared_spec", :request_for_quotation, attributes)
    end
  end
end
