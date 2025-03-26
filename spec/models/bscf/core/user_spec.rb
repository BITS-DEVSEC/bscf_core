require 'rails_helper'

module Bscf
  module Core
    RSpec.describe User, type: :model do
      attributes = [
        { first_name: :presence },
        { middle_name: :presence },
        { last_name: :presence },
        { password: :presence },
        { phone_number: %i[presence uniqueness] },
        { email: %i[presence uniqueness] }
      ]
      include_examples("model_shared_spec", :user, attributes)
    end
  end
end
