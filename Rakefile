require "bundler/setup"

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"
Dir[File.join(File.dirname(__FILE__), 'lib/tasks/**/*.rake')].each { |f| load f }
