FROM asciidoctor/docker-asciidoctor:latest

WORKDIR /docs

# 1. 日本語フォント (Noto CJK) とフォント管理ツール (fontconfig) を追加
RUN apk add --no-cache \
      graphviz \
      nodejs \
      npm \
      chromium \
      nss \
      freetype \
      freetype-dev \
      harfbuzz \
      ca-certificates \
      ttf-dejavu \
      font-noto-cjk \
      fontconfig && \
    fc-cache -fv && \
    gem install asciidoctor-diagram && \
    npm install -g @mermaid-js/mermaid-cli

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Create Puppeteer config to enable --no-sandbox
RUN cat > /root/.puppeteerrc.cjs <<'EOF'
const {join} = require('path');
module.exports = {
cacheDirectory: join(__dirname, '.cache', 'puppeteer'),
executablePath: '/usr/bin/chromium',
launchArgs: ['--no-sandbox', '--disable-setuid-sandbox'],
skipDownload: true,
};

EOF
COPY scripts/ /scripts/

CMD ["/scripts/build.sh"]
