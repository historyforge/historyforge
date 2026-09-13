# syntax=docker/dockerfile:1
ARG RUBY_VERSION=4.0.6
FROM node:22-bookworm-slim AS node
FROM ruby:${RUBY_VERSION}-slim-bookworm AS base
ENV RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1
WORKDIR /app
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    libpq5 libvips imagemagick locales postgresql-client libyaml-0-2 ca-certificates \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen \
    && rm -rf /var/lib/apt/lists/*

ENV BUNDLE_PATH=/usr/local/bundle

FROM base AS build
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential git pkg-config libpq-dev libyaml-dev libssl-dev libffi-dev \
    libcurl4-openssl-dev liblzma-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack \
    && corepack enable
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 5 && rm -rf /usr/local/bundle/cache
COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install --immutable
COPY . .
COPY lib/docker/database.yml config/database.yml
RUN yarn build \
    && SECRET_KEY_BASE_DUMMY=1 DEPLOYING=true bundle exec rails assets:precompile \
    && rm -rf node_modules .yarn/cache tmp/cache

FROM base AS runtime
ARG REVISION=unknown
LABEL org.opencontainers.image.revision=$REVISION
RUN groupadd --gid 32767 herokuishuser \
    && useradd --uid 32767 --gid 32767 --home-dir /app --shell /bin/bash herokuishuser
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=32767:32767 /app /app
RUN mkdir -p tmp/pids log storage && chown 32767:32767 /app && chown -R 32767:32767 tmp log storage
USER herokuishuser
EXPOSE 5000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "5000"]
