source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'aws-sdk-ecs', '~> 1' # used to trigger harvests
gem 'aws-sdk-s3' # used by Active Storage
gem 'aws-sdk-sns', '~> 1' # used to send SNS messages to trigger Lambda functions
gem 'bootstrap', '~> 4.1'
gem 'scars-bootstrap-theme', github: 'medusa-project/scars-bootstrap-theme'
gem 'faraday'
gem 'image_processing', '~> 1.2' # rescales uploaded representative images
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'js_cookie_rails'
gem 'local_time'
gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'pg'
gem 'puma'
gem 'rails', '~> 5.2.0'
gem 'sassc'
gem 'uglifier', '>= 1.3.0'

gem 'mini_racer', platforms: :ruby

group :development, :test do
  #gem 'bootsnap'
  gem 'listen', '>= 3.0.5', '< 3.2'
end
