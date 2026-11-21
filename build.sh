#!/bin/sh
# Builds index.html (served by GitHub Pages or Home Assistant /local/) from src/hub.html.
set -e
cd "$(dirname "$0")"
{
  printf '%s\n' '<!doctype html>' '<html lang="de">' '<head>' \
    '<meta charset="utf-8">' \
    '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">' \
    '<meta name="apple-mobile-web-app-capable" content="yes">' \
    '<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">' \
    '<meta name="apple-mobile-web-app-title" content="Zuhause">' \
    '<meta name="theme-color" content="#0b1020">' \
    '</head>' '<body>'
  cat src/hub.html
  printf '%s\n' '</body>' '</html>'
} > index.html
echo "index.html written ($(wc -c < index.html) bytes)"
