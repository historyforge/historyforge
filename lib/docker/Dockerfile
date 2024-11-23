FROM ruby:3.3.6

ENV DEBIAN_FRONTEND noninteractive
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install packages
RUN apt-get update -qq && \
  apt-get install -y \
  automake build-essential patch zlib1g-dev liblzma-dev git \
  libssl-dev libreadline-dev \
  libyaml-dev libcurl4-openssl-dev libffi-dev \
  libpq-dev libvips locales postgresql-client

# Clean up
RUN \
  apt-get autoremove -y && \
  apt-get autoclean && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# So the system doesn't complain about unable to set locale
RUN locale-gen en_US.UTF-8

RUN gem install bundler

RUN mkdir /app
WORKDIR /app

ADD Gemfile ./Gemfile
ADD Gemfile.lock ./Gemfile.lock

RUN bundle config set without 'development:test' \
    && bundle install --jobs 20 --retry 5

COPY . .

