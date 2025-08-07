FROM rubylang/ruby:3.4.4-dev-noble

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get -y install --no-install-recommends libvips libvips-dev libvips-tools libpq-dev python3-pygments libz-dev libssl-dev libffi-dev libyaml-dev

LABEL   org.opencontainers.image.authors="Jacrys <kclewis0614@gmail.com>" \
        org.opencontainers.image.source="${REPO_URL}" \
        org.opencontainers.vendor="Jacrys" \
        org.opencontainers.image.licenses="MIT" \
        org.opencontainers.image.title="${REPO_HUMAN_NAME} Development Container" \
        org.opencontainers.image.description="Development container for the ${REPO_HUMAN_NAME} project, providing a Ruby environment with necessary dependencies and tools." \
        org.opencontainers.image.base_image="rubylang/ruby:3.4.4-dev-noble" \
        org.opencontainers.image.version="3.4.4" \
        org.opencontainers.image.documentation="${REPO_URL}/blob/main/.devcontainer/README.md"

# Copy the entire project to a staging area
COPY . /tmp/project-staging/

# Copy setup scripts to system location
COPY .devcontainer/entrypoint.sh /usr/local/bin/dev-entrypoint.sh
COPY .devcontainer/setup-volume-workspace.zsh /usr/local/bin/setup-volume-workspace.zsh
COPY .devcontainer/setup.zsh /usr/local/bin/setup.zsh
COPY .devcontainer/postSetup.zsh /usr/local/bin/postSetup.zsh
RUN chmod +x /usr/local/bin/dev-entrypoint.sh /usr/local/bin/setup-volume-workspace.zsh /usr/local/bin/setup.zsh /usr/local/bin/postSetup.zsh

ENTRYPOINT ["/usr/local/bin/dev-entrypoint.sh"]
CMD [ "zsh" ]

# [Optional] Uncomment this line to install global node packages.
# RUN su dev -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1
USER root