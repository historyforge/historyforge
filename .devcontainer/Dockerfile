FROM mcr.microsoft.com/devcontainers/base:noble

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get -y install --no-install-recommends libvips

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US
ENV LANG=en_US.UTF-8
ENV LC_TIME=en_GB.UTF-8
ENV LC_CTYPE=en_US.UTF-8
# [Optional] Uncomment this line to install additional gems.
# RUN su dev -c "gem install <your-gem-names-here>"

# [Optional] Uncomment this line to install global node packages.
# RUN su dev -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1
USER vscode