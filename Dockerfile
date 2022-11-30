FROM ruby:2.7-slim-bullseye

## Install System Dependencies
RUN apt-get update -y
RUN apt-get install -y git zip curl ca-certificates gnupg lsb-release python3.9 python3-venv python3-pip awscli

## Setup Python
ENV POETRY_HOME=/etc/poetry
RUN curl -sSL https://install.python-poetry.org | python3.9 - --version 1.1.13
ENV PATH="${PATH}:/${POETRY_HOME}/bin"

## Setup Docker https://docs.docker.com/engine/install/debian/
RUN mkdir -p /etc/apt/keyrings
RUN  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update -y
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

## Install Serverless Tools
COPY . .

RUN gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"
RUN bundle install
RUN bundle exec rake install

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
