# BubbleChat: iOS App

SwiftUI client for BubbleChat, a video-first messaging app. Targets **iOS 17** and is built entirely with SwiftUI.

This folder is a sanitized public showcase of the production iOS codebase: comments and user-facing strings have been translated to English, and secrets plus the development tunnel endpoint have been replaced with placeholders. The production host is shown as a placeholder (`your-domain.example`).

## Architecture

The app uses a **dual transport** strategy:

- **gRPC bidirectional streaming** (`grpc-swift`): realtime messaging and presence. A long-lived client↔server stream pushes new posts/comments, contact activity, and online/offline status, and carries outbound messages back to the server.
- **REST over Moya / Alamofire**: media upload/download and CRUD (auth, contacts, profile, history). Requests are authenticated with a bearer token injected by a Moya plugin.

Local state is persisted in a **GRDB (SQLite)** store and read reactively by the SwiftUI views. Auth tokens live in the **Keychain**.

## Modules

| Module | Responsibility |
| --- | --- |
| `GrpcManager` | gRPC connection lifecycle, the bidirectional stream, and the provider/use-case handlers that turn server events into local DB writes (posts, comments, contact activity, presence). |
| `WebRequestManager` | Moya/Alamofire stack: custom session, retry interceptor, logging, and the bearer-token auth plugin for REST calls. |
| `DatabaseManager` | GRDB setup, migrations, and the typed read/write helpers over the SQLite store (chats, media, users). |
| `CacheManager` | On-disk cache for media files (categorized save/load/exists/clear). |
| `ContactsManager` | Device contacts access, periodic sync, and upload of contacts to the backend. |
| `UserManager` | Current-user state and identity. |
| `CameraManager` | AVFoundation capture session, recording, flash control, and video processing (square crop, preview/duration extraction). |
| `Notifications` | Push-notification registration and forwarding the device token to the server. |

Supporting modules: `DataManager`, `QueueRequestManager`, `ErrorManager`, `Sound`.

## Tech stack

- SwiftUI, iOS 17
- `grpc-swift` (gRPC bidirectional streaming)
- Moya + Alamofire (REST)
- GRDB (SQLite)
- KeychainAccess (token storage)
- Kingfisher / NukeUI (image loading & caching)
- Lottie (animations)
- AVFoundation (camera / video)

## Configuration

Backend endpoints are defined in `BubbleChat/Constants.swift`:

- `HOST` / `GRPC_HOST` / `GRPC_PORT`: production backend (public).
- `DEV_GRPC_HOST` / `DEV_GRPC_PORT`: development gRPC endpoint, set to a placeholder. Point this at your own dev tunnel to run against a local backend.

## Build

> **Note:** The generated Protobuf + gRPC Swift sources (`ProtobufModels/`) are produced by codegen from the shared contract in [`proto/`](../proto/) and are excluded from this repo. Building the iOS target requires running protoc with the swift + grpc-swift plugins against `proto/`. This repository showcases the architecture and application code.

1. Open `BubbleChat.xcodeproj` in Xcode (15+).
2. Swift Package Manager resolves dependencies from the committed `Package.resolved`.
3. Generate the `ProtobufModels/` sources from [`proto/`](../proto/) (protoc + swift / grpc-swift plugins).
4. Select an iOS 17 simulator or device and build/run.
