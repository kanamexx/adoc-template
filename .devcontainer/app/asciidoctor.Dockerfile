ARG ASCIIDOCTOR_VERSION=1.103.0
FROM docker.io/asciidoctor/docker-asciidoctor:${ASCIIDOCTOR_VERSION}

WORKDIR /docs

# 1. 日本語フォント (Noto CJK) とフォント管理ツール (fontconfig) を追加
RUN apk add --no-cache \
      graphviz \
      font-noto-cjk \
      fontconfig \
      wget && \
    fc-cache -fv && \
    gem install asciidoctor-kroki

# Environment variables for Kroki
ENV KROKI_SERVER_URL=http://kroki:8000

COPY scripts/ /scripts/

CMD ["/scripts/build.sh"]
