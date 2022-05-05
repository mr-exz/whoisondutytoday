FROM ruby:2.7
ARG DOCKER_IMAGE_TAG

ENV DOCKER_IMAGE_TAG=$DOCKER_IMAGE_TAG

RUN apt-get update -qq && apt-get install -y nodejs cron \
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

EXPOSE 3000

CMD ["./bin/start"]