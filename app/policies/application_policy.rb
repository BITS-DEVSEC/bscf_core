class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  private

  def admin?
    user.user_roles.any? { |ur| ur.role.name == "Admin" }
  end

  def driver?
    user.user_roles.any? { |ur| ur.role.name == "Driver" }
  end

  def user_role?
    user.user_roles.any? { |ur| ur.role.name == "User" }
  end
end
