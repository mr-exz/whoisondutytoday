FROM ruby:2.6.3

RUN apt-get update -qq && apt-get install -y nodejs
RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

COPY . /myapp
RUN yarn install --check-files

EXPOSE 3000

CMD ["./bin/start"]