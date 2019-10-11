source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'aws-sdk-ecs', '~> 1' # used to trigger harvests
gem 'bootstrap', '~> 4.3'
gem 'scars-bootstrap-theme', github: 'medusa-project/scars-bootstrap-theme'
gem 'faraday'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'js_cookie_rails'
gem 'local_time'
gem 'marc-dates', git: 'https://github.com/medusa-project/marc-dates.git'
gem 'mini_racer', platforms: :ruby
gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'pg'
gem 'rails', '~> 5.2.3'
gem 'sassc'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  #gem 'bootsnap'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'puma'
end

group :production do
  gem 'passenger'
end
