#!/bin/bash
echo "Building HTML and PDF from AsciiDoc (multilingual)..."

LANGUAGES="ja en"

for LANG in $LANGUAGES; do
    echo ""
    echo "=========================================="
    echo "Building $LANG version..."
    echo "=========================================="
    
    cd /docs/$LANG
    
    echo "Generating HTML ($LANG)..."
    asciidoctor -r asciidoctor-diagram -a allow-uri-read -a scripts=cjk -a mermaid-puppeteer-config=../puppeteer-config.json -a data-uri -a mask -D /output/$LANG index.adoc
    
    echo "Copying assets ($LANG)..."
    mkdir -p /output/$LANG/images
    cp -r ../images/* /output/$LANG/images/
    
    echo "Generating PDF ($LANG)..."
    asciidoctor-pdf -r asciidoctor-diagram -a allow-uri-read -a scripts=cjk -a pdf-theme=default-with-fallback-font -a mermaid-puppeteer-config=../puppeteer-config.json -D /output/$LANG index.adoc
done

echo ""
echo "Build complete! Files available in output/ja/ and output/en/"
