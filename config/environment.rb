# Load the Rails application.
require_relative 'application'

if Rails.env.development? or Rails.env.test?
  Rails.logger = ActiveSupport::Logger.new(STDOUT)
end

# Initialize the Rails application.
Rails.application.initialize!
