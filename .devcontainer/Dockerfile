FROM node:22-bookworm-slim AS node
FROM ruby:4.0.6-bookworm

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && ln -s /usr/local/lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack \
    && corepack enable \
    && apt-get update \
    && apt-get install -y --no-install-recommends git libpq-dev postgresql-client libvips imagemagick chromium chromium-driver \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspaces/historyforge
CMD ["sleep", "infinity"]
