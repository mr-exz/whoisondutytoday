FROM ruby:2.6.3

ENV SLACK_API_TOKEN=REPLACE_ME

RUN apt-get update -qq && apt-get install -y nodejs
RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

COPY . /myapp

EXPOSE 3000

CMD ["./bin/rails", "server"]