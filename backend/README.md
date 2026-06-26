# Bubble Chat: Backend (Swift / Vapor)

Backend for the Bubble Chat messaging app. Built with [Vapor](https://vapor.codes)
on Swift, it exposes a **REST API** for account and resource management and a
**gRPC bidirectional streaming API** for the real-time messaging layer.

> Secrets are not shipped with this repository. All credentials are read from the
> environment (see `.env.example`), and the APNs `.p8` key must be supplied
> locally in `Resources/` (gitignored).

## Features

**REST (HTTP)**
- Phone-number authentication via flash-call verification (sms.ru), the user enters the last 4 digits of the calling number, issuing **JWT** access tokens.
- Users (fetch, update device token).
- Chats / dialogues and chat members.
- Contacts upload.
- Asset / media upload and retrieval (images, video) with preview handling.

**gRPC (bidirectional streaming)**
- Real-time messages ("posts"), comments, and reactions.
- Presence / user activity and contact-with-activity subscriptions.
- Delivery & read tracking (delivery status: sending, sent, delivered, read, failed, deleted, edited).
- An outbound queue + server-to-client fan-out to connected streams.

## Tech stack

- **Vapor**: HTTP server, routing, middleware.
- **Fluent + FluentPostgresDriver**: ORM over **PostgreSQL**.
- **gRPC Swift**: bidirectional streaming services (definitions under
  `Sources/App/ProtobufModels/Proto`, generated code under `.../Swift`).
- **Soto (SotoS3)**: **Yandex Object Storage** (S3-compatible) for media.
- **APNS / APNSwift**: iOS push notifications via an Apple `.p8` auth key.
- **JWT**: HS256 access tokens.

## Project layout

```
Sources/App/
  configure.swift            App bootstrap: DB, APNs, JWT, S3, gRPC, migrations
  routes.swift               REST route registration
  Controllers/               REST controllers (Auth, Operation, Asset)
  Managers/GrpcManager/      gRPC providers, request/response handlers
  Managers/DatabaseManager/  DB access helpers
  Middleware/                e.g. user-id extraction
  Migrations/                Fluent migrations + mock data seeding
  Models/                    Fluent models
  ProtobufModels/            .proto sources + generated Swift + strict wrappers
Resources/                   Place your APNs AuthKey_XXXXXXXXXX.p8 here (gitignored)
Public/                      Static file root (currently only .gitkeep)
Dockerfile                   Release build image (Swift 6.0)
```

## Configuration

All configuration is environment-driven. See **`.env.example`** for the full list:
PostgreSQL (`DATABASE_*`), `JWT_SECRET`, APNs (`APNS_KEY_ID` / `APNS_TEAM_ID` /
`APNS_TOPIC` / `APNS_KEY_PATH`), S3 / Yandex Object Storage
(`S3_ACCESS_KEY` / `S3_SECRET_KEY` / `S3_ENDPOINT` / `S3_VIDEO_BUCKET` /
`S3_PREVIEW_BUCKET`), and SMS (`SMS_API_ID`).

The app **fails fast** on startup if the required S3 credentials are not set.

## Running

1. **Configure environment**
   ```bash
   cp .env.example .env
   # then edit .env with your own values
   ```

2. **Provide your APNs key**
   Put your Apple `.p8` auth key in `Resources/` (e.g. `Resources/AuthKey_XXXXXXXXXX.p8`)
   and point `APNS_KEY_PATH` at it. The file is gitignored and is never committed.

3. **Have PostgreSQL available** and matching your `DATABASE_*` values. Migrations
   run automatically on boot.

4. **Build & run**
   ```bash
   # Local build
   swift build -c release
   .build/release/App serve --env production

   # or via Docker. NOTE: the Dockerfile only builds the release binary and
   # defines no ENTRYPOINT/CMD, so pass the run command explicitly:
   docker build -t bubble-backend .
   docker run --env-file .env -p 8080:8080 bubble-backend \
     .build/release/App serve --env production --hostname 0.0.0.0
   ```

   The HTTP server listens on port **8080** (`127.0.0.1` in DEBUG, `0.0.0.0` otherwise).

> No `docker-compose.yml` ships with this repo. If you want one-command local
> startup, add a compose file that runs PostgreSQL alongside this service and
> wires in the `.env` file.

## Security notes

- No `.p8` / `.pem` / `.key` / `.crt` / `.p12` private keys are included.
- No real S3, SMS, APNs, or database credentials are hardcoded. All are read
  from the environment with placeholder defaults only.
- Keep your `.env` and your APNs key out of version control (already covered by
  `.gitignore`).
