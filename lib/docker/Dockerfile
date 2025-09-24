FROM ruby:3.4.5

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
  libpq-dev libvips locales postgresql-client && \
  apt-get autoremove -y && \
  apt-get autoclean && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Generate and configure locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    echo 'export LANG=en_US.UTF-8' >> /etc/bash.bashrc && \
    echo 'export LC_ALL=en_US.UTF-8' >> /etc/bash.bashrc

RUN gem install bundler

RUN mkdir /app
WORKDIR /app

ADD Gemfile ./Gemfile
ADD Gemfile.lock ./Gemfile.lock

RUN bundle config set without 'development:test' \
    && bundle install --jobs 20 --retry 5

COPY . .

