# syntax=docker/dockerfile:1
FROM pandoc/extra:edge

ENV TERM=xterm

RUN apk add --no-cache \
    bash \
    curl \
    git \
    make \
    ncurses \
    perl \
    python3 \
    python3-dev \
    py3-pip \
    py3-setuptools \
    py3-wheel \
    rsync \
    unzip \
    wget \
    zip \
    && rm -rf /var/cache/apk/*

RUN tlmgr update --self \
  && tlmgr install \
      catchfile \
      context \
      datetime2 \
      dejavu \
      emoji \
      eso-pic \
      koma-script \
      lastpage \
      minted \
      moresize \
      newunicodechar \
      noto-emoji \
      pgf \
      pgfopts \
      plex \
      sectsty \
      sourcecodepro \
      titlesec \
      tocloft \
      ucs \
      xcolor-material \
      xstring \
  && luaotfload-tool --update \
  && chmod o+w /opt/texlive/texdir/texmf-var 

ENTRYPOINT ["pandoc"]