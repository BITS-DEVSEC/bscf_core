FactoryBot.define do
  factory :user_role, class: "Bscf::Core::UserRole" do
    user
    role
  end
end
