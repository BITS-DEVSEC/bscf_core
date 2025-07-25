module Bscf
  module Core
    class UserRolePolicy < Bscf::Core::ApplicationPolicy
      def assign_driver?
        admin?
      end
    end
  end
end
