FROM ruby:2.7.2

ENV DEBIAN_FRONTEND noninteractive
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

# Curl lets us get node and yarn in the next step
RUN apt-get update -qq && apt-get install -y curl

# Install node 12 LTS and yarn
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install packages
RUN apt-get update -qq && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
  automake build-essential patch zlib1g-dev liblzma-dev git \
  libssl-dev libreadline-dev \
  libyaml-dev libcurl4-openssl-dev libffi-dev \
  libpq-dev nodejs yarn libvips

# Clean up
RUN \
  apt-get autoremove -y && \
  apt-get autoclean && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem install bundler

RUN mkdir /app
WORKDIR /app

ADD Gemfile ./Gemfile
ADD Gemfile.lock ./Gemfile.lock

RUN bundle config set without 'development:test' \
    && bundle install --jobs 20 --retry 5

COPY . .

