module Bscf
  module Core
    class UserProfilePolicy < Bscf::Core::ApplicationPolicy
      def show?
        true
      end

      def update_kyc?
        admin?
      end
    end
  end
end
