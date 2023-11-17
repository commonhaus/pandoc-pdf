# syntax=docker/dockerfile:1
FROM pandoc/latex:3.1

RUN tlmgr update --self \
  && tlmgr install context sectsty lastpage emoji dejavu noto-emoji plex ucs newunicodechar \
  && luaotfload-tool --update \
  && chmod o+w /opt/texlive/texdir/texmf-var 

ENTRYPOINT ["pandoc"]