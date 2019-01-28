FROM node:8

LABEL maintainer="Erin Schnabel <schnabel@us.ibm.com> (@ebullientworks)"

RUN  apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade -y \
  && apt-get -qq install -y apt-utils busybox curl wget jq \
  && wget https://github.com/jgm/pandoc/releases/download/2.5/pandoc-2.5-1-amd64.deb \
  && dpkg -i pandoc-2.5-1-amd64.deb \
  && apt-get install -y -f \
  && apt-get -qq clean \
  && rm -rf /tmp/* /var/lib/apt/lists/*

ENV PATH="${PATH}:/usr/local/lib/node_modules/marked-it-cli/bin"
RUN npm install -g marked-it-cli \
  && npm install -g npm \
  && npm install -g bower \
  && echo 'export PATH=$PATH:/usr/local/lib/node_modules/marked-it-cli/bin' >> /etc/bash.bashrc

