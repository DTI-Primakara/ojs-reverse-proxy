# ==========================================
#  Primakara E-Journal (Custom OJS Build)
#  PHP 7.4 + Apache + Cron + Supervisor
# ==========================================
FROM php:7.4-apache

LABEL maintainer="Primakara E-Journal <admin@primakara.ac.id>"
LABEL version="3.1"
LABEL description="Custom OJS image (PHP 7.4) with env-aware config, Supervisor, cron, and reverse proxy support"

# --- System dependencies ---
RUN apt-get update && apt-get install -y \
  unzip git libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev libicu-dev libonig-dev vim \
  libzip-dev zip locales cron supervisor curl \
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

# --- Set permissions ---
RUN mkdir -p /var/www/files \
  && chown -R www-data:www-data /var/www/html /var/www/files \
  && chmod -R 775 cache public /var/www/files \
  && chmod 664 config.inc.php || true

# --- Silence deprecated notices for PHP 7.x ---
RUN echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE" > /usr/local/etc/php/conf.d/error-level.ini \
  && echo "display_errors = Off" >> /usr/local/etc/php/conf.d/error-level.ini \
  && echo "log_errors = On" >> /usr/local/etc/php/conf.d/error-level.ini

EXPOSE 80
HEALTHCHECK --interval=1m --timeout=5s CMD curl -fs http://localhost/ || exit 1


CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]

