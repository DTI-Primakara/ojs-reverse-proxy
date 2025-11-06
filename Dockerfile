# ==========================================
#  Primakara E-Journal (Custom OJS Build)
#  Apache + Cron managed via Supervisor
# ==========================================
FROM php:8.3-apache

LABEL maintainer="Primakara E-Journal <admin@primakara.ac.id>"
LABEL version="3.0"
LABEL description="Custom OJS image using env-aware config, Supervisor, unified logging, and reverse proxy compatibility"

# --- Install dependencies ---
RUN apt-get update && apt-get install -y \
  unzip git libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev libicu-dev \
  libzip-dev zip libonig-dev locales cron supervisor curl \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install gd intl pdo pdo_mysql zip opcache mbstring xml \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# --- Copy OJS source (local) ---
COPY . /var/www/html

# --- Patch reverse-proxy compatibility ---
RUN sed -i 's/function getBaseUrl()$/function getBaseUrl($allowProtocolRelative = true)/' lib/pkp/classes/core/PKPRequest.inc.php

# --- Enable Apache modules ---
RUN a2enmod rewrite expires headers

# --- Add cron job ---
COPY cron.d-ojs /etc/cron.d/ojs
RUN chmod 0644 /etc/cron.d/ojs && crontab /etc/cron.d/ojs

# --- Add Supervisor config ---
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# --- Clean URLs and HTTPS header fix ---
RUN echo 'SetEnvIf X-Forwarded-Proto "https" HTTPS=on' > /var/www/html/.htaccess \
  && echo '<IfModule mod_rewrite.c>\nRewriteEngine On\nRewriteCond %{REQUEST_FILENAME} !-f\nRewriteCond %{REQUEST_FILENAME} !-d\nRewriteRule ^ index.php [L]\n</IfModule>' >> /var/www/html/.htaccess

# --- Permissions ---
RUN mkdir -p /var/www/files \
  && chown -R www-data:www-data /var/www/html /var/www/files \
  && chmod -R 775 cache public /var/www/files \
  && chmod 664 config.inc.php || true

EXPOSE 80

# --- Healthcheck for Coolify ---
HEALTHCHECK --interval=1m --timeout=5s CMD curl -fs http://localhost/ || exit 1

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]

