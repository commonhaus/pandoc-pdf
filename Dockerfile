FROM node:8

LABEL maintainer="Erin Schnabel <schnabel@us.ibm.com> (@ebullientworks)"


RUN  apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade -y \
  && apt-get -qq install -y apt-utils busybox curl wget \
  && wget https://github.com/jgm/pandoc/releases/download/2.3.1/pandoc-2.3.1-1-amd64.deb \
  && dpkg -i pandoc-2.3.1-1-amd64.deb \
  && apt-get install -y -f \
  && apt-get -qq clean \
  && rm -rf /tmp/* /var/lib/apt/lists/*



