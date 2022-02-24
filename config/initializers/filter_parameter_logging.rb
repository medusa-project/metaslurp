# Be sure to restart your server when you modify this file.

# By default, Rails logs all parameters. This is a problem in this application
# because they may contain huge amounts of text. So we filter them out.
# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.

if Rails.env.production? || Rails.env.demo?
  Rails.application.config.filter_parameters += [/\w+/]
end
