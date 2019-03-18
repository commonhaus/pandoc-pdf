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

RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
  && tar xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
  && mv wkhtmltox/bin/* /usr/local/bin

ENV PATH="${PATH}:/usr/local/lib/node_modules/marked-it-cli/bin"
RUN npm install -g marked-it-cli \
  && npm install -g npm \
  && npm install -g bower \
  && npm install -g gulp \
  && npm install -g sass \
  && echo 'export PATH=$PATH:/usr/local/lib/node_modules/marked-it-cli/bin' >> /etc/bash.bashrc

COPY npm_wrap /usr/local/bin