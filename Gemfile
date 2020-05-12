source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem "autoprefixer-rails" # required to avoid some bootstrap CSS weirdness
gem 'aws-sdk-ecs', '~> 1' # used to trigger harvests
gem 'faraday'
gem "font-awesome-sass", "~> 5.6"
gem 'jbuilder'
gem 'jquery-rails'
gem 'js_cookie_rails'
gem 'local_time'
gem 'marc-dates', git: 'https://github.com/medusa-project/marc-dates.git'
gem 'mini_racer', platforms: :ruby
gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'pg'
gem 'rails', '~> 6.0.3'
gem 'sassc'
gem 'scars-bootstrap-theme', github: 'medusa-project/scars-bootstrap-theme',
    branch: 'release/bootstrap-4.4'
#gem 'scars-bootstrap-theme', path: '/path/to/scars-bootstrap-theme'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  #gem 'bootsnap'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'puma'
end

group :production do
  gem "omniauth-rails_csrf_protection"
  gem 'passenger'
end
