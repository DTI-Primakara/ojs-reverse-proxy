# OJS dengan Reverse Proxy Support

PKP OJS ([https://pkp.sfu.ca/ojs/](https://pkp.sfu.ca/ojs/))
terkostumisasi agar dapat berjalan di balik reverse proxy. Versi
OJS ini dibuat dengan versi 3.3 LTS yang akan mendapatkan update hingga 2027.
Project ini dibuat untuk memudahkan proses deployment dengan Docker platform. 
Ideal untuk melakukan deployment dengan Coolify, Dockploy, atau Portainer serta 
cloud based IaaS platform lainnya.

## Build Image

Clone repository ini dan build Docker image:
```
docker build -t ojs .
```

## Run Container

> Apache di dalam container diset dengan HTTPS header, jika dijalankan pada 
localhost, akan mengasilkan redirection looping. 

1. Sesuaikan env variable dengan `cp .env.example .env`, TLRD;:
```
OJS_BASE_URL=https://your.journal.domain
OJS_FILES_DIR=/var/www/files
OJS_TIMEZONE=Asia/Makassar

OJS_DB_USER=
OJS_DB_HOST=
OJS_DB_PASSWORD=
OJS_DB_NAME=

OJS_SALT=s0m3Rand0mStr1ng
OJS_API_KEY_SECRET=someapisecret

OJS_SMTP_SERVER=
OJS_SMTP_PORT=
OJS_SMTP_AUTH=
OJS_SMTP_USERNAME=
OJS_SMTP_PASSWORD=
OJS_MAIL_FROM=

OJS_REPOSITORY_ID=your_journal_id_with_domain
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

Butuh dukungna teknis? Hubungi kami via dti@primakara.ac.id
