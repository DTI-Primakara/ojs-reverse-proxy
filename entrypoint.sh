#!/bin/sh

set -e

TEMPLATE=/var/www/html/config.inc.php.template
TARGET=/var/www/html/config.inc.php

# Generate config.inc.php from template
sed \
  -e "s/{{DB_HOST}}/${DB_HOST}/" \
  -e "s/{{DB_USER}}/${DB_USER}/" \
  -e "s/{{DB_PASS}}/${DB_PASS}/" \
  -e "s/{{DB_NAME}}/${DB_NAME}/" \
  -e "s/{{DB_PORT}}/${DB_PORT}/" \
  -e "s/{{SMTP_HOST}}/${SMTP_HOST}/" \
  -e "s/{{SMTP_PORT}}/${SMTP_PORT}/" \
  -e "s/{{SMTP_AUTH}}/${SMTP_AUTH}/" \
  -e "s/{{SMTP_USER}}/${SMTP_USER}/" \
  -e "s/{{SMTP_PASS}}/${SMTP_PASS}/" \
  -e "s|{{APP_URL}}|${APP_URL}|" \
  "$TEMPLATE" >"$TARGET"

echo "Generated OJS config.inc.php"
exec "$@"
