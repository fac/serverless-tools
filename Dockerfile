FROM docker:20.10-dind

RUN apk upgrade
RUN apk update

# Install Ruby
## We're pinning this to ruby 2.7 as that's what Serverless tools currently supports.
RUN apk add ruby-full=2.7.6-r0 ruby-dev=2.7.6-r0 --repository https://dl-cdn.alpinelinux.org/alpine/v3.14/main/

RUN gem install bundler

# Lock Python to 3.9 as that's the version used in our functions
RUN apk add python3=3.9.15-r0 python3-dev=3.9.15-r0 --repository https://dl-cdn.alpinelinux.org/alpine/v3.14/main/
RUN apk add libffi-dev=3.3-r2 libffi=3.3-r2 --repository https://dl-cdn.alpinelinux.org/alpine/v3.14/main/
RUN python3 -m ensurepip
RUN pip3 install --upgrade pip setuptools virtualenv awscli

# Add in all the native dependencies we need to run bundle, poetry, and serverless-tools etc.
RUN apk add git curl zip gcc pkgconfig libc-dev

# Setup Poetry for Python functions
ENV POETRY_HOME=/etc/poetry
RUN curl -sSL https://install.python-poetry.org | python3 - --version 1.1.13
ENV PATH="${PATH}:/${POETRY_HOME}/bin"

# Install Serverless-Tools
COPY . .

RUN bundle config set --global without 'development'
RUN bundle install
RUN bundle add rake
RUN bundle exec rake install

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
