# Be sure to restart your server when you modify this file.

# By default, Rails logs all parameters at info level. This is a problem
# because they may contain huge amounts of text. Since there is apparently no
# easy way to get Rails to log them at debug level instead, we'll just filter
# them out.
if Rails.env.production?
  Rails.application.config.filter_parameters += [/\w+/]
end
