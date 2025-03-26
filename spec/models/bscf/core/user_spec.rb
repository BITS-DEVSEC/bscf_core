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
        { email: %i[presence uniqueness] },
        { user_profile: :have_one },
        { user_roles: :have_many },
        { roles: :have_many }
      ]
      include_examples("model_shared_spec", :user, attributes)
    end
  end
end
