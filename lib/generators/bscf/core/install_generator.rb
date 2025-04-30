module Bscf
  module Core
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      desc "Install BSCF Core"

      def copy_migrations
        say_status :copying, "migrations"
        rake "bscf_core:install:migrations"
      end

      def mount_engine
        route "mount Bscf::Core::Engine => '/bscf'"
      end

      def run_migrations
        say_status :running, "migrations"
        rake "db:migrate"
      end

      def finished
        say "BSCF Core has been installed successfully!"
      end
    end
  end
end
