FROM ruby:2.5.3

ARG secret_key_base

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV SECRET_KEY_BASE=$secret_key_base

RUN mkdir app
WORKDIR app

# Copy the Gemfile as well as the Gemfile.lock and install gems.
# This is a separate, earlier step in order to cache dependencies.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --without development test --jobs 20 --retry 5

# Copy the main application, except whatever is listed in .dockerignore.
COPY . ./

RUN bin/rails assets:precompile

EXPOSE 3000

#ENTRYPOINT ["bin/rails", "db:migrate"]

CMD ["bin/puma"]
