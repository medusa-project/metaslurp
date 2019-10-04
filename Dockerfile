FROM ruby:2.6.2

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_MAX_THREADS=5
ENV RAILS_SERVE_STATIC_FILES=false

RUN mkdir app
WORKDIR app

# Copy the Gemfile as well as the Gemfile.lock and install gems.
# This is a separate, earlier step in order to cache dependencies.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --without development test --jobs 20 --retry 5

# Copy the main application, except whatever is listed in .dockerignore.
# This includes /config/master.key which will be needed to decrypt the
# credentials.
COPY . ./

RUN bin/rails assets:precompile

EXPOSE 3000

# N.B.: --engine=builtin works around an issue with the embedded nginx where
# large POST requests cause HTTP 5xx errors.
CMD ["bundle", "exec", "passenger", "start", "-p", "3000", "--engine=builtin", "--max-pool-size=32", "--min-instances=32", "--log-file=/dev/stdout"]
