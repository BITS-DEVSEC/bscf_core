module Bscf
  module Core
    class UserPolicy < Bscf::Core::ApplicationPolicy
      def index?
        admin?
      end

      def show?
        admin?
      end

      def by_role?
        admin?
      end

      def has_virtual_account?
        true
      end
    end
  end
end
