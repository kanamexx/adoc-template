#!/bin/bash
echo "Building HTML and PDF from AsciiDoc (multilingual)..."

echo "Cleaning up output directory..."
if [ -d /output ]; then
    find /output -mindepth 1 -maxdepth 1 -exec rm -rf {} +
fi

# Wait for Kroki server to be ready
echo "Waiting for Kroki server ($KROKI_SERVER_URL) to be ready..."
MAX_RETRIES="${KROKI_MAX_RETRIES:-60}"
SLEEP_SECONDS="${KROKI_RETRY_INTERVAL:-1}"
TIMEOUT_SECONDS=$(awk "BEGIN{print ${MAX_RETRIES}*${SLEEP_SECONDS}}")
attempt=0

until curl -s "$KROKI_SERVER_URL/health" | grep -q 'pass'; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge "$MAX_RETRIES" ]; then
    echo ""
    echo "ERROR: Kroki server ($KROKI_SERVER_URL) did not become ready after ${MAX_RETRIES} attempts (timeout ${TIMEOUT_SECONDS} seconds)." >&2
    exit 1
  fi
  printf '.'
  sleep "$SLEEP_SECONDS"
done
echo " Kroki is ready!"

LANGUAGES="ja en"

for LANG in $LANGUAGES; do
    echo ""
    echo "=========================================="
    echo "Building $LANG version..."
    echo "=========================================="
    
    mkdir -p /tmp/build/$LANG
    cd /tmp/build/$LANG
    
    echo "Generating HTML ($LANG)..."
    cp -r /docs/$LANG/* .
    asciidoctor -r asciidoctor-kroki \
        -a allow-uri-read \
        -a scripts=cjk \
        -a kroki-server-url=$KROKI_SERVER_URL \
        -a kroki-fetch-diagram=true \
        -a imagesoutdir=. \
        -a imagesdir=. \
        -a data-uri -a mask \
        -D /output/$LANG \
        index.adoc
    
    echo "Copying assets ($LANG)..."
    mkdir -p /output/$LANG/images
    cp -r /docs/images/* /output/$LANG/images/
    
    echo "Generating PDF ($LANG)..."
    cp -r /docs/$LANG/* .
    
    mkdir -p ../images ../pdf-configs
    cp -r /docs/images/* ../images/ 2>/dev/null || true
    cp -r /docs/pdf-configs/* ../pdf-configs/ 2>/dev/null || true

    if [ "$LANG" = "ja" ]; then
        THEME_OPTS="-a pdf-theme=../pdf-configs/styles-ja.yml"
    else
        THEME_OPTS="-a pdf-theme=../pdf-configs/style.yml"
    fi

    # Config for Kroki Mermaid to handle Japanese fonts
    MERMAID_CONFIG='{"fontFamily": "Noto Sans CJK JP, sans-serif", "theme": "default"}'

    # 英語ビルド時に style.yml 内の存在しないフォント (M+ 1mn 等) でエラーになるのを防ぐため
    if [ "$LANG" = "ja" ]; then
        FONT_OPTS="-a pdf-fontsdir=/usr/share/fonts/noto"
    else
        FONT_OPTS="-a pdf-fontsdir=$GEM_FONTS_DIR"
    fi

    asciidoctor-pdf -r asciidoctor-kroki \
        -a allow-uri-read \
        -a scripts=cjk \
        -a kroki-server-url=$KROKI_SERVER_URL \
        -a "mermaid-config=$MERMAID_CONFIG" \
        -a "kroki-default-format=png" \
        -a "kroki-format-mermaid=png" \
        -a "kroki-format-d2=svg" \
        -a "kroki-mermaid-options=text=path" \
        -a "kroki-d2-options=font-family=Noto%20Sans%20CJK%20JP" \
        -a kroki-fetch-diagram=true \
        -a imagesoutdir=. \
        -a imagesdir=. \
        $FONT_OPTS \
        $THEME_OPTS \
        -D /output/$LANG \
        index.adoc
done

echo ""
echo "Build complete! Files available in output/ja/ and output/en/"
