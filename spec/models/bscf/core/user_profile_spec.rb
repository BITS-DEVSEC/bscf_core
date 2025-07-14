require 'rails_helper'

module Bscf
  module Core
    RSpec.describe UserProfile, type: :model do
      attributes = [
        { date_of_birth: :presence },
        { nationality: :presence },
        { gender: :presence },
        { user: :belong_to },
        { address: :belong_to }
      ]
      include_examples("model_shared_spec", :user_profile, attributes)

      it { is_expected.to belong_to(:verified_by).class_name('User').optional }
    end
  end
end
