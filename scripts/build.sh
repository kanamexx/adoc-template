#!/bin/bash
echo "Building HTML and PDF from AsciiDoc..."

echo "Generating HTML..."
asciidoctor -r asciidoctor-diagram -a allow-uri-read -a scripts=cjk -a mermaid-puppeteer-config=puppeteer-config.json -a data-uri -a mask -D ../output index.adoc

echo "Copying assets..."
cp -r images ../output/images

echo "Generating PDF..."
asciidoctor-pdf -r asciidoctor-diagram -a allow-uri-read -a scripts=cjk -a pdf-theme=default-with-fallback-font -a mermaid-puppeteer-config=puppeteer-config.json -D ../output index.adoc

echo "Build complete! Files available in output/"
