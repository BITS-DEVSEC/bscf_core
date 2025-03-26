require 'rails_helper'

module Bscf
  module Core
    RSpec.describe UserRole, type: :model do
      attributes = [
        { user: :belong_to },
        { role: :belong_to }
      ]
      include_examples("model_shared_spec", :user_role, attributes)
    end
  end
end
