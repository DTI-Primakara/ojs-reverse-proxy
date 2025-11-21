#!/bin/sh

set -e

TEMPLATE="/var/www/html/config.inc.php.template"
TARGET="/var/www/html/config.inc.php"

echo "Generating config.inc.php from template..."

# Default behaviour: overwrite every start (safe for containerized OJS)
# If someone sets FORCE_CONFIG=0, we skip regeneration
if [ -f "$TARGET" ] && [ "$FORCE_CONFIG" = "0" ]; then
  echo "FORCE_CONFIG=0 → Skipping config generation. Using existing config.inc.php."
else
  # Ensure TEMPLATE exists
  if [ ! -f "$TEMPLATE" ]; then
    echo "ERROR: $TEMPLATE not found!"
    exit 1
  fi

  sed \
    -e "s|{{INSTALLED}}|${INSTALLED}|g" \
    -e "s|{{APP_URL}}|${APP_URL}|g" \
    -e "s|{{APP_TIMEZONE}}|${APP_TIMEZONE}|g" \
    -e "s|{{DB_HOST}}|${DB_HOST}|g" \
    -e "s|{{DB_USER}}|${DB_USER}|g" \
    -e "s|{{DB_PASS}}|${DB_PASS}|g" \
    -e "s|{{DB_NAME}}|${DB_NAME}|g" \
    -e "s|{{DB_PORT}}|${DB_PORT}|g" \
    -e "s|{{FILES_DIR}}|${FILES_DIR}|g" \
    -e "s|{{FORCE_SSL}}|${FORCE_SSL}|g" \
    -e "s|{{APP_SALT}}|${APP_SALT}|g" \
    -e "s|{{API_KEY_SECRET}}|${API_KEY_SECRET}|g" \
    -e "s|{{SMTP_ENABLED}}|${SMTP_ENABLED}|g" \
    -e "s|{{SMTP_HOST}}|${SMTP_HOST}|g" \
    -e "s|{{SMTP_PORT}}|${SMTP_PORT}|g" \
    -e "s|{{SMTP_AUTH}}|${SMTP_AUTH}|g" \
    -e "s|{{SMTP_USER}}|${SMTP_USER}|g" \
    -e "s|{{SMTP_PASS}}|${SMTP_PASS}|g" \
    -e "s|{{SMTP_FROM}}|${SMTP_FROM}|g" \
    -e "s|{{OAI_REPO_ID}}|${OAI_REPO_ID}|g" \
    "$TEMPLATE" >"$TARGET"

  echo "config.inc.php generated successfully."
fi

# Permissions — ensure www-data can read/write
chown www-data:www-data "$TARGET" || true
chmod 664 "$TARGET" || true

echo "Starting Supervisor (Apache + Cron)..."
exec "$@"
