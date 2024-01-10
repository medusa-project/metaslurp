#
# Dockerfile for use in production.
#

FROM ruby:3.2.2-slim

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_MAX_THREADS=5
ENV RAILS_SERVE_STATIC_FILES=true
ENV WEB_CONCURRENCY=4

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    git \
    nodejs \
    shared-mime-info

RUN mkdir app
WORKDIR app

# Copy the Gemfile as well as the Gemfile.lock and install gems.
# This is a separate, earlier step in order to cache dependencies.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler \
    && bundle config set without 'development test' \
    && bundle install --jobs 20 --retry 5

# Copy the main application, except whatever is listed in .dockerignore.
COPY . ./

RUN bin/rails assets:precompile

EXPOSE 3000

# This command invokes Passenger.
# See: https://www.phusionpassenger.com/library/config/standalone/
#
# We aren't using Passenger anymore due to HTTP 502 errors in response to
# certain large request bodies that were difficult to debug. It's probably
# possible to tune Passenger's embedded nginx to fix this, but it was easier
# to just switch to Puma.
#CMD ["bundle", "exec", "passenger", "start", "-p", "3000", "--engine=builtin", "--max-pool-size=16", "--min-instances=16", "--log-file=/dev/stdout"]

# See config/puma.rb
CMD ["bundle", "exec", "puma"]
