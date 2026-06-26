# Infra: nginx reverse proxy + PostgreSQL

Deployment environment for the Bubble chat backend (a Vapor/Swift app). This folder
contains everything needed to run the app behind an nginx reverse proxy with a
PostgreSQL database, via Docker Compose.

> The backend itself (`BubbleBackendVapor`) and all TLS keys/certs are **not** included.
> Clone the backend yourself and bring your own TLS certificate (see below).

## Components

- **nginx**: reverse proxy in front of the app. Routes:
  - `/api/*` → app HTTP/REST/WebSocket server (`:8080`), with token auth via the
    `auth_request` subrequest to `/auth/check_token_header`.
  - `/` → app gRPC server (`:50051`) over HTTP/2.
  - Dev (`Dockerfile` + `templates/default.conf.template`) proxies to
    `host.docker.internal`; prod (`Dockerfile.prod` + `templates/prod.conf.template`)
    proxies to the `app` service and terminates TLS on `:443`.
- **postgres**: PostgreSQL 17. Credentials come from the environment (`.env`).
  Data is persisted in `./Postgres/data`; one-time init scripts can be placed in
  `./Postgres/init` (see `Postgres/init/01-init.sql.example`).
- **app**: your Vapor backend. In prod it is built from `./BubbleBackendVapor`
  (clone it first, see the `Makefile`).
- **dozzle** (prod only): lightweight container log viewer on port `6002`.

## Layout

```
infra/
├── docker-compose-dev.yml    # local/dev stack
├── docker-compose-prod.yml   # production stack (TLS, dozzle, app build)
├── Makefile                  # clone backend + build/up helpers
├── .env.example              # copy to .env and fill in
├── Nginx/
│   ├── Dockerfile            # dev image
│   ├── Dockerfile.prod       # prod image
│   ├── templates/            # nginx config templates
│   └── certs/                # <- put your TLS cert/key here (gitignored)
└── Postgres/
    ├── data/                 # data volume (gitignored, created at runtime)
    └── init/                 # optional one-time init scripts
```

## Configuration

Copy the example env file and set real values:

```bash
cp .env.example .env
# edit .env: POSTGRES_USER / POSTGRES_PASSWORD / POSTGRES_DB
```

Both compose files read these variables, so the same `.env` works for dev and prod.

## Deploy

Prerequisites: Docker + Docker Compose.

### Development

```bash
docker compose -f docker-compose-dev.yml up --build
```

nginx listens on `:80` and proxies to the app running on the Docker host
(`host.docker.internal:8080` / `:50051`).

### Production

1. Clone the backend so the `app` image can be built:

   ```bash
   make del-clone-repo   # edit the repo URL in the Makefile first
   ```

2. Provide a TLS certificate (see below).

3. Build and start:

   ```bash
   docker compose -f docker-compose-prod.yml up --build -d
   ```

   nginx serves `:80` and `:443`; logs are viewable via dozzle on `:6002`.

The `Makefile` also wraps these (`make docker-build-dev`, `make docker-build-prod`).

## Bring your own TLS certificate

No certificates or private keys are shipped in this repo. The prod nginx config
expects them at:

- `/etc/nginx/certs/your-domain.crt`
- `/etc/nginx/certs/your-domain.key`

These are mounted from `./Nginx/certs` (gitignored) by `docker-compose-prod.yml`.

1. Set your real domain in `Nginx/templates/prod.conf.template` (replace
   `your-domain.example` and the cert file names).
2. Obtain a certificate, e.g. with certbot / Let's Encrypt:

   ```bash
   sudo certbot certonly --standalone -d your-domain.example
   ```

3. Copy the issued `fullchain.pem` / `privkey.pem` into `./Nginx/certs` as
   `your-domain.crt` / `your-domain.key` (or adjust the paths in the template).

> Never commit private keys or certificates. `Nginx/certs/`, `.env`, and
> `Postgres/data/` are gitignored.
