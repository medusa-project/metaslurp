source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'aws-sdk-ecs', '~> 1' # used to trigger harvests
gem 'bootstrap', '~> 4.3'
gem 'scars-bootstrap-theme', github: 'medusa-project/scars-bootstrap-theme'
gem 'faraday'
gem 'jbuilder'
gem 'jquery-rails'
gem 'js_cookie_rails'
gem 'local_time'
gem 'marc-dates', git: 'https://github.com/medusa-project/marc-dates.git'
gem 'mini_racer', platforms: :ruby
gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'pg'
gem 'rails', '~> 6.0.1'
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
