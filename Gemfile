source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'aws-sdk-ecs', '~> 1'
gem 'aws-sdk-sns', '~> 1'
gem 'bootstrap', '~> 4.1.0'
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

group :development, :test do
  gem 'bootsnap'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'thin'
end

group :production do
  gem 'passenger', '~> 4.0.60'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
