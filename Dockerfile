FROM ruby:2.7-slim-bullseye

RUN apt-get update -y
RUN apt-get install -y git zip python3.9
RUN curl -sSL https://install.python-poetry.org | python3 - --version 1.1.13
ENV PATH="${PATH}:/root/.poetry/bin"

COPY . .

RUN bundle install
RUN bundle exec rake install
RUN echo $(gem env)
RUN echo $(gem list)

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
