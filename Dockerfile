FROM ruby:2.7-slim-buster

RUN apt-get update -y
RUN apt-get install -y git zip

COPY . .

RUN bundle install
RUN bundle exec rake install
RUN echo $(gem env)
RUN echo $(gem list)

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
