source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'bootstrap-sass', '~> 3.3.6'
gem 'font-awesome-sass', '~> 4.7.0'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'pg'
gem 'rails', '~> 5.1.4'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'puma'
end

group :production do
  gem 'passenger', '~> 4.0.60'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
