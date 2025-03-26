require 'rails_helper'

module Bscf
  module Core
    RSpec.describe Role, type: :model do
      attributes = [
        { name: :presence }
      ]
      include_examples("model_shared_spec", :role, attributes)
    end
  end
end
