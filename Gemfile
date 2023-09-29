source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem "autoprefixer-rails" # required to avoid some bootstrap CSS weirdness
gem 'aws-sdk-ecs', '~> 1' # used to trigger harvests
gem 'faraday'
gem "font-awesome-sass", "~> 5.6"
gem 'haml'
gem 'haml-rails'
gem 'jbuilder'
gem 'jquery-rails'
gem 'js_cookie_rails'
gem 'local_time'
gem 'marc-dates', git: 'https://github.com/medusa-project/marc-dates.git'
gem 'mini_racer', platforms: :ruby
gem 'omniauth'
gem 'omniauth-shibboleth'
gem "omniauth-rails_csrf_protection"
gem 'pg'
gem 'puma', '~> 5'
gem 'rails', '~> 7.0'
gem 'sassc'
gem 'scars-bootstrap-theme', github: 'medusa-project/scars-bootstrap-theme',
    branch: 'release/bootstrap-4.4'
#gem 'scars-bootstrap-theme', path: '../scars-bootstrap-theme'
gem 'sprockets-rails'
gem 'uglifier', '>= 1.3.0'
gem 'uiuc_lib_ad', git: 'https://github.com/UIUCLibrary/uiuc_lib_ad.git'

group :development, :test do
  gem 'listen', '>= 3.0.5', '< 3.2'
end
