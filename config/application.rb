require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Metaslurp
  class Application < Rails::Application
    attr_accessor :shibboleth_host

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Make pages embeddable within other websites.
    config.action_dispatch.default_headers =
        config.action_dispatch.default_headers.delete('X-Frame-Options')
  end
end
