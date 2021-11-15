FROM ruby:2.7-alpine3.14

RUN apk --no-cache add zip

RUN mkdir /servless-tools

WORKDIR /serverless-tools

COPY Gemfile /serverless-tools/Gemfile
COPY Gemfile.lock /severless-tools/Gemfile.lock

RUN bundle config set without 'development' 'test'
RUN bundle install

COPY lib /serverless-tools/lib

ENTRYPOINT ["bundle", "exec", "ruby", "/serverless-tools/lib/deployer.rb"]
