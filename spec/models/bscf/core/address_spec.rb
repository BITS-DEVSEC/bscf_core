require 'rails_helper'

module Bscf::Core
  RSpec.describe Address, type: :model do
    attributes = []
    include_examples("model_shared_spec", :address, attributes)
  end
end
