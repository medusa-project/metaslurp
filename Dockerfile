# This Dockerfile is for running the web application in demo & production.
# There is a separate Dockerfile in docker/metaslurp for running the tests.
# (Also see docker-compose.yml which is related to that file and not this one.)

FROM ruby:2.7.1-slim

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_MAX_THREADS=5
ENV RAILS_SERVE_STATIC_FILES=true
ENV WEB_CONCURRENCY=4

RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
  curl \
  git

RUN mkdir app
WORKDIR app

# Copy the Gemfile as well as the Gemfile.lock and install gems.
# This is a separate, earlier step in order to cache dependencies.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle config set without 'development test' && bundle install --jobs 20 --retry 5

# Copy the main application, except whatever is listed in .dockerignore.
# This includes the /config/credentials/*.key files which are needed to decrypt
# the credentials.
COPY . ./

RUN bin/rails assets:precompile

EXPOSE 3000

# This command invokes Passenger.
# See: https://www.phusionpassenger.com/library/config/standalone/
#
# We aren't using Passenger anymore due to HTTP 502 errors in response to
# certain large request bodies that were difficult to debug. It's probably
# possible to tune it to fix this, but it was easier to just switch to Puma.
#CMD ["bundle", "exec", "passenger", "start", "-p", "3000", "--engine=builtin", "--max-pool-size=16", "--min-instances=16", "--log-file=/dev/stdout"]

# See config/puma.rb
CMD ["bundle", "exec", "puma"]
