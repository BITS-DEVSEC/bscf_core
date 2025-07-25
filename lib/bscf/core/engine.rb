module Bscf
  module Core
    class Engine < ::Rails::Engine
      isolate_namespace Bscf::Core
      config.autoload_paths << File.expand_path("../../app/policies", __dir__)
      config.generators.api_only = true

      config.generators do |g|
        g.test_framework :rspec, routing_specs: false
        g.fixture_replacement :factory_bot
        g.factory_bot dir: "spec/factories"
      end

      initializer "bscf_core.factories", after: "factory_bot.set_factory_paths" do
        FactoryBot.definition_file_paths << File.expand_path("../../../spec/factories", __dir__) if defined?(FactoryBot)
      end

      initializer :append_migrations do |app|
        unless app.root.to_s.match(root.to_s + File::SEPARATOR)
          app.config.paths["db/migrate"].concat(config.paths["db/migrate"].expanded)
        end
      end

      require "active_storage/engine"
    end
  end
end
