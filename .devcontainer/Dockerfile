FROM rubylang/ruby:3.3.7-dev-noble

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get -y install --no-install-recommends libvips libvips-dev libvips-tools libpq-dev python3-pygments libz-dev libssl-dev libffi-dev libyaml-dev

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US
ENV LANG=en_US.UTF-8
ENV LC_TIME=en_GB.UTF-8
ENV LC_CTYPE=en_US.UTF-8

# Copy the entire project to a staging area
COPY . /tmp/project-staging/

# Copy setup scripts to system location
COPY .devcontainer/entrypoint.sh /usr/local/bin/dev-entrypoint.sh
COPY .devcontainer/setup-volume-workspace.sh /usr/local/bin/setup-volume-workspace.sh
COPY .devcontainer/setup.sh /usr/local/bin/setup.sh
COPY .devcontainer/postSetup.sh /usr/local/bin/postSetup.sh
RUN chmod +x /usr/local/bin/dev-entrypoint.sh /usr/local/bin/setup-volume-workspace.sh /usr/local/bin/setup.sh /usr/local/bin/postSetup.sh

ENTRYPOINT ["/usr/local/bin/dev-entrypoint.sh"]
CMD [ "zsh" ]

# [Optional] Uncomment this line to install global node packages.
# RUN su dev -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1
USER root