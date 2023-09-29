#
# Dockerfile for use in continuous integration.
#

FROM ruby:3.2.2-slim

# This is checked in various places in the app & tests to tailer for a CI
# environment (where adding another Rails environment would be overkill)
ENV CI=1
ENV RAILS_ENV=test
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_MAX_THREADS=5
ENV RAILS_SERVE_STATIC_FILES=true
ENV WEB_CONCURRENCY=4

RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
  curl \
  git \
  shared-mime-info

RUN mkdir app
WORKDIR app

# Copy the Gemfile as well as the Gemfile.lock and install gems.
# This is a separate, earlier step in order to cache dependencies.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler \
    && bundle config set without 'development' \
    && bundle install --jobs 20 --retry 5

# Copy the main application, except whatever is listed in .dockerignore.
COPY . ./

RUN cp config/credentials/ci.yml config/credentials/test.yml

CMD ["cat", "/dev/null"]
