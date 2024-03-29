require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Metaslurp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Make pages embeddable within other websites. (Spurlock needs this and
    # it's also done in Kumquat)
    config.action_dispatch.default_headers =
        config.action_dispatch.default_headers.delete('X-Frame-Options')

    # Wards off a segmentation fault when compiling sassc in docker
    config.assets.configure do |env|
      env.export_concurrent = false
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
