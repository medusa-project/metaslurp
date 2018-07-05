source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'aws-sdk-ecs', '~> 1' # used to trigger harvests
gem 'aws-sdk-sns', '~> 1' # used to send SNS messages to trigger Lambda functions
gem 'bootstrap', '~> 4.1.1'
gem 'scars-bootstrap-theme', github: 'medusa-project/scars-bootstrap-theme'
gem 'faraday'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'js_cookie_rails'
gem 'local_time'
gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'pg'
gem 'rails', '~> 5.2.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

# Updated by recommendation of a GitHub security check
gem 'sprockets', '~> 3.7.2'

group :development, :test do
  gem 'bootsnap'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'thin'
end

group :production do
  # N.B.: Elastic Beanstalk is very picky about the specific version used.
  # See: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/platform-history-ruby.html
  gem 'passenger', '~> 4.0.60'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
