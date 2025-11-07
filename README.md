# Primakara Ejournal

PKP OJS ([https://pkp.sfu.ca/ojs/](https://pkp.sfu.ca/ojs/))
terkostumisasi yang dibuat khusus agar bisa berjalan di balik reverse proxy. Versi
OJS ini dibuat dengan versi 3.3 LTS yang akan mendapatkan update hingga 2027.
Project ini dibuat untuk memudahkan proses deployment dengan Docker platform. Ideal untuk melakukan deployment dengan Coolify, Dockploy, atau Portainer.

## Build Image

```
docker build -t primakara/ejournal .
```

## Run Container

> Apache di dalam container diset dengan HTTPS header, jadi secara teknis tidak memungkinkan menjalankan container tanpa HTTPS. 

1. Sesuaikan env variable dengan `cp .env.example .env`, TLRD;:
```
OJS_BASE_URL=https://ejournla.primakara.ac.id
OJS_FILES_DIR=/var/www/files
OJS_TIMEZONE=Asia/Makassar

OJS_DB_USER=ejournal
OJS_DB_HOST=mariadb
OJS_DB_PASSWORD=ejournal
OJS_DB_NAME=ejournal

OJS_SALT=s0m3Rand0mStr1ng
OJS_API_KEY_SECRET=

OJS_SMTP_SERVER=smtp.mailgun.org
OJS_SMTP_PORT=587
OJS_SMTP_AUTH=tls
OJS_SMTP_USERNAME=postmaster@ejournal.primakara.ac.id
OJS_SMTP_PASSWORD=supersecret
OJS_MAIL_FROM=admin@ejournal.primakara.ac.id

OJS_REPOSITORY_ID=ejournal.primakara.ac.id
```
2. Run docker container:
```
docker run -d \
  --name primakara-ejournal \
  -p 8989:80 \
  --env-file .env \
  -v ojs_files_data:/var/www/files \
  primakara/ejournal
```

3. Opsional

Untuk memudahkan konfigurasi dan update di masa depan, bind volume
directory:
- `/var/www/html`
- `/var/www/files` (sesuai dengan `$OJS_FILES_DIR`)

> Pastikan bind volume dilakukan setelah proses installation selesai. Jika tidak, directory OJS akan kosong.

## Reverse Proxy dengan Nginx
```
server {
    server_name ejournal.primakara.ac.id ;

    location / {
        proxy_pass http://localhost:989;
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
traefik.http.routers.<container_id>.rule=Host(`ejournal.primakara.ac.id`) && PathPrefix(`/`)
traefik.http.routers.<container_id>.service=<container_id>
traefik.http.routers.https-0-<container_id>.entryPoints=https
traefik.http.routers.https-0-<container_id>.middlewares=gzip
traefik.http.routers.https-0-<container_id>.rule=Host(`ejournal.primakara.ac.id`) && PathPrefix(`/`)
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
caddy_0.handle_path=ejournal.primakara.ac.id*
caddy_0.header=-Server
caddy_0.try_files={path} /index.html /index.php
caddy_0=https://ejournal.primakara.ac.id
caddy_ingress_network=coolify
```

## Future Development

- [ ] Mekanisme upgrade
