# OJS dengan Reverse Proxy Support

PKP OJS ([https://pkp.sfu.ca/ojs/](https://pkp.sfu.ca/ojs/))
terkostumisasi agar dapat berjalan di balik reverse proxy. Versi
OJS ini dibuat dengan versi 3.3 LTS yang akan mendapatkan update hingga 2027.
Project ini dibuat untuk memudahkan proses deployment dengan Docker platform.
Ideal untuk melakukan deployment dengan Coolify, Dockploy, atau Portainer serta
cloud based IaaS platform lainnya.

## Build Image

1. Clone repository ini
2. Edit php.ini untuk menyesuaikan konfigurasi php di dalam container
3. Build image

```
docker build -t ojs .
```

## Run Container

> Apache di dalam container diset dengan HTTPS header, jika dijalankan pada
localhost, akan mengasilkan redirection looping.

1. Sesuaikan env variable dengan `cp .env.example .env`, TLRD;:

```
INSTALLED=Off
APP_URL=https://sub.domain.com
APP_TIMEZONE=Asia/Makassar
DB_HOST=db
DB_USER=username
DB_PASS=password                                                        |
DB_NAME=dbname
DB_PORT=3306
FILES_DIR="/var/www/files"
FORCE_SSL=On
APP_SALT=32karakter
API_KEY_SECRET=32karakter
SMTP_ENABLED=On
SMTP_HOST=some.smtphost.com
SMTP_PORT=2525
SMTP_AUTH=tls
SMTP_USER=smtpuser
SMTP_PASS=smtppassword
SMTP_FROM=from@domain.com
OAI_REPO_ID=sub.domain.com
```

2. Run docker container:

```
docker run -d \
  --name ojs \
  -p 8989:80 \
  --env-file .env \
  -v ojs_files_data:/var/www/files \
  ojs
```

3. Opsional

Untuk memudahkan konfigurasi dan update di masa depan, bind volume
directory:

- `/var/www/html`
- `/var/www/files` (sesuai dengan `$OJS_FILES_DIR`)

> Pastikan bind volume dilakukan setelah proses web installation selesai.

## Reverse Proxy dengan Nginx

```
server {
    server_name your.journal.domain;

    location / {
        proxy_pass http://localhost:9898;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
 proxy_set_header X-Forwarded-Proto https;

    }

    listen 80;
}
```

## Reverse Proxy dengan Traefik

```
traefik.enable=true
traefik.http.middlewares.gzip.compress=true
traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https
traefik.http.routers.<container_id>.entryPoints=http
traefik.http.routers.<container_id>.middlewares=redirect-to-https
traefik.http.routers.<container_id>.rule=Host(`your.journal.domain`) && PathPrefix(`/`)
traefik.http.routers.<container_id>.service=<container_id>
traefik.http.routers.https-0-<container_id>.entryPoints=https
traefik.http.routers.https-0-<container_id>.middlewares=gzip
traefik.http.routers.https-0-<container_id>.rule=Host(`your.journal.domain`) && PathPrefix(`/`)
traefik.http.routers.https-0-<container_id>.service=https-0-<container_id>
traefik.http.routers.https-0-<container_id>.tls.certresolver=letsencrypt
traefik.http.routers.https-0-<container_id>.tls=true
traefik.http.services.<container_id>.loadbalancer.server.port=80
traefik.http.services.https-0-<container_id>.loadbalancer.server.port=80
```

## Reverse Proxy dengan Caddy

```
caddy_0.encode=zstd gzip
caddy_0.handle_path.0_reverse_proxy={{upstreams 80}}
caddy_0.handle_path=your.journal.domain*
caddy_0.header=-Server
caddy_0.try_files={path} /index.html /index.php
caddy_0=https://your.journal.domain
caddy_ingress_network=coolify
```

## Future Development

- [ ] Mekanisme upgrade

Project ini dirawat oleh
[Direktorat Teknologi Informasi Primakara University](https://dti.primakara.ac.id).

Butuh dukungna teknis? Hubungi kami via <dti@primakara.ac.id>
