Rails.application.routes.draw do
  mount Bscf::Core::Engine => "/bscf-core"
end
