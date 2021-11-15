FROM ruby:2.7-alpine3.14

RUN apk --no-cache add zip

WORKDIR /github/workspace

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle config set without 'development' 'test'
RUN bundle install

COPY lib lib

ENTRYPOINT ["bundle", "exec", "ruby", "lib/deployer.rb"]
