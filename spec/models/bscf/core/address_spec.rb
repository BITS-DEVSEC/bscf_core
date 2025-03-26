require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Address, type: :model do
      attributes = [
        { user_profiles: :have_many }
      ]
      include_examples("model_shared_spec", :address, attributes)
    end
  end
end
