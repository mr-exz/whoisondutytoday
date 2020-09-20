FROM ruby:2.6.3-alpine3.10
HEALTHCHECK NONE

RUN apk add --no-cache build-base yarn nodejs vim imagemagick sqlite sqlite-dev tzdata curl
RUN gem install bundler

WORKDIR /myapp
COPY Gemfile* /myapp/
RUN bundle install

COPY . /myapp
RUN yarn install --check-files

EXPOSE 3000

CMD ["./bin/start"]