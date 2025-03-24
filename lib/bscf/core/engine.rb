module Bscf
  module Core
    class Engine < ::Rails::Engine
      isolate_namespace Bscf::Core
      config.generators.api_only = true
    end
  end
end
