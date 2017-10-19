module MailyHerald
  module Api
    class Engine < ::Rails::Engine
      isolate_namespace MailyHerald::Api

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_girl, :dir => 'spec/support/factories'
      end

      config.autoload_paths += Dir["#{config.root}/lib/**/"]
    end
  end
end
