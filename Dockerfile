FROM ruby:3.3.6-slim
ARG DOCKER_IMAGE_TAG

ENV DOCKER_IMAGE_TAG=$DOCKER_IMAGE_TAG

RUN echo "deb http://deb.debian.org/debian/ stable main contrib" > /etc/apt/sources.list && rm /etc/apt/sources.list.d/debian.sources

RUN apt-get update -qq && apt-get install -y nodejs cron ubuntu-dev-tools \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && mkdir /myapp \
    && crontab -l | { cat; echo ""; } | crontab -

WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

COPY . /myapp
RUN bundle exec whenever --update-crontab

RUN sed -i "s/if Gem::Version.new(Async::WebSocket::VERSION) >= Gem::Version.new('0.9.0')/if Gem::Version.new(Async::WebSocket::VERSION) >= Gem::Version.new('0.30.0')/" \
    /usr/local/bundle/gems/slack-ruby-client-2.4.0/lib/slack/real_time/concurrency/async.rb

EXPOSE 3000

CMD ["./bin/start"]