FROM ruby:2.5.3

ARG time_zone

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_MAX_THREADS=5
ENV RAILS_SERVE_STATIC_FILES=true
ENV TIME_ZONE=$time_zone

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

#ENTRYPOINT ["bin/rails", "db:migrate"]

CMD ["bin/rails", "server"]
