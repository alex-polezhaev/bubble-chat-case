# Bubble Chat iOS Messenger

**An iOS messenger with a Vapor backend and gRPC streaming.**

**Period:** 2023-2024
**Role:** Full-stack, iOS + Backend
**Stack:** SwiftUI (iOS 17) · Swift / Vapor · gRPC · Protobuf · PostgreSQL (Fluent) · GRDB · Soto (S3) · APNs · AVFoundation

---

## The Product

Bubble Chat is a messenger built around short video. Instead of typing, people record "bubbles" (square video clips captured right inside the app) and reply with reactions and threaded comments. On top of each video users place interactive layers: text, GIFs, and stickers, each with its own position, scale, and rotation. The result is a conversation made of moving, expressive clips rather than text lines.

Two product surfaces had to feel instant: capturing/sending a bubble, and receiving one. Everything below is in service of those two moments feeling real-time, reliable, and lossless even on flaky mobile networks.

---

## The Challenge

A video-first messenger raises problems a text app never faces:

- **Heavy payloads.** Every message is a video file plus a preview frame, not a few hundred bytes of text. Uploads must not block the UI, and a dropped upload must never silently lose a message.
- **Hard real-time.** Presence ("typing", "recording now"), delivery receipts, and incoming content all need to arrive within seconds, in both directions, over a single long-lived connection.
- **Guaranteed delivery.** Mobile connections drop constantly. A message composed offline, or while the socket is mid-reconnect, has to survive and be delivered exactly once when connectivity returns.
- **One shared domain model.** The same entities (posts, comments, reactions, layers, delivery status) live on the server, travel over the wire, and are cached on the device. Keeping three hand-written copies of those models in sync is a recipe for drift.

---

## The Solution at a Glance

- A **native SwiftUI app (iOS 17)** with a local **GRDB / SQLite** store as the source of truth for the UI, so the app is fully usable offline and updates optimistically.
- A **Swift / Vapor backend** with **PostgreSQL via Fluent**, sharing one language with the client.
- **Protobuf contracts** compiled into a single shared target used by both the server and the iOS client. The domain model is defined once.
- **gRPC bidirectional streaming** (grpc-swift) for everything real-time: outgoing content, incoming content, and contact/presence activity.
- **Moya / Alamofire REST** for media upload and CRUD, with files stored in **Yandex Object Storage (S3)** through **Soto**.
- **APNs** push notifications for delivery while the app is backgrounded.

### Evolution

An earlier version of the backend ran as eight Node.js microservices (auth, sockets, asset handling, push, operations, nginx, log viewer) on Docker Compose with MongoDB, paired with a React Native client. The system was rewritten to a **Swift / Vapor + native iOS** stack to collapse the whole platform onto one language and one set of Protobuf-defined models, eliminating duplicated contracts between client and server. Everything described below is the current Swift system.

---

## Architecture

### Protobuf contracts: one model, many surfaces

The entire domain is described in `.proto` files and compiled into a target shared by the server and the app, so models are never duplicated.

```protobuf
enum PostType  { BUBBLE = 1; FRAME = 2; TOPIC = 3; }
enum MediaType { VIDEO  = 1; IMAGE = 2; }
enum LayerType { TEXT   = 1; GIF   = 2; STICKER = 3; }
```

A **Layer** is an interactive overlay on a video with normalized coordinates, so it renders identically at any screen size:

```protobuf
message LayerEntity {
    LayerType layer_type = 4;
    double x = 5; double y = 6; double scale = 7; double rotation = 8;
    oneof attribute {
        TextAttributes    textAttributes    = 9;
        GifAttributes     gifAttributes     = 10;
        StickerAttributes stickerAttributes = 11;
    }
}
```

**Delivery status** is an explicit enum that drives receipts across the system:

```protobuf
enum DeliveryStatus {
    UPLOADING = 1; SENDING = 2; SENT = 3;
    DELIVERED = 4; READ = 5; FAILED = 6; DELETED = 7; EDITED = 8;
}
```

**Dual IDs** on every entity make optimistic UI possible:

```protobuf
message PostId { string server = 1; string client = 2; }
```

The client generates a `client` ID before sending, so the UI can update immediately. Once the server confirms, it returns a `server` ID that the two halves reconcile.

### Strict Proto types: a validation layer over generated code

The Protobuf generator produces types where every field is optional. To turn that into a safe, non-optional domain model, each payload has a hand-written `Strict` counterpart with required fields and proper Swift types (`UUID` instead of `String`, `Date` instead of an ISO string), plus parsing and serialization that validate on the way in and out:

```swift
struct Request_SendReactionPayload_Strict {
    var reactionClientId: UUID      // UUID, not String
    var emoji: String
    var timestamp: Date             // Date, not an ISO string
    var postServerId: UUID?         // a reaction targets a post...
    var commentServerId: UUID?      // ...or a comment

    // Validation while parsing from protobuf
    init(from entity: Entities_ReactionEntity) throws {
        reactionClientId = try parseUUID(from: entity.reactionID.client)
        timestamp = try parseDate(from: entity.timestamp.isoDate)
        emoji = entity.emoji
        // ...
    }

    // Serialize back to protobuf + a round-trip self-check
    func toProto() -> Entities_ReactionEntity {
        let result = Entities_ReactionEntity.with { /* ... */ }
        // fatalError in dev if the result can't be re-parsed - catches serialization bugs early
        let _ = try Request_SendReactionPayload_Strict(from: result)
        return result
    }
}
```

Shared parsers use `#function` so the failing field names itself in the error:

```swift
func parseUUID(from string: String, fieldName: String = #function) throws -> UUID {
    guard let uuid = UUID(uuidString: string) else {
        throw ValidationError.invalidField("Invalid \(fieldName): \(string)")
    }
    return uuid
}
```

---

## Real-time: three bidirectional gRPC streams

All live traffic runs over three concurrent bidirectional gRPC streams between the app and Vapor:

```
iOS  ──── ClientToServer  ────→  Vapor
     ←─── ServerToClient  ─────
     ←─── ContactActivity ─────
```

**ClientToServer**: the client sends posts, comments, reactions, layers, and delivery-status updates; the server answers with a confirmation carrying the same `request_id`.

**ServerToClient**: delivery of incoming content. On the server, `ClientStreamRegistry` is a Swift `actor` mapping `userId → responseStream` for online users. A background loop sweeps every active connection every two seconds and flushes any pending requests:

```swift
actor ClientStreamRegistry {
    private var userStreams: Set<UserStream> = []

    private func runTasks() async {
        while true {
            for userStream in userStreams {
                try await QueueRequestManager(app: app)
                    .sendPendingRequests(userId: userStream.userId)
            }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }
}
```

**ContactWithUserActivity**: contact sync and presence. The server pushes updates roughly every 1.5 seconds:

```protobuf
enum UserStatus {
    ONLINE = 1; OFFLINE = 2; TYPING = 3; ACTIVE = 4; CAPTURING = 5;
}
```

`CAPTURING` means the other person is recording a video right now. The recipient sees it live in the UI.

### Guaranteed delivery: the QueueRequest

Every outgoing action is persisted before it is trusted to the network.

**On iOS (GRDB).** Each outgoing request is serialized and stored locally until acknowledged. On reconnect, every record still marked `success == nil` is re-sent:

```swift
func sendPendingRequests() {
    let requests = try AppDatabase.shared.dbPool.read { db in
        try QueueRequest.filter(Column("success") == nil).fetchAll(db)
    }
    requests.forEach { try? deSerializeAndSend(queueRequest: $0) }
}
```

**On Vapor (PostgreSQL).** A mirror queue holds requests for recipients who are offline. After 50 failed attempts a request is marked `failed`. A two-second grace period guards against double-sending a request the moment it is created:

```swift
.filter(\.$createdAt < Date().addingTimeInterval(-2))
```

### Auto-reconnect

Each stream provider reconnects recursively the instant the stream breaks:

```swift
} catch {
    clean()
    try? await Task.sleep(nanoseconds: 1_500_000_000)
    startStream()
}
```

`GRPCManager` publishes `connectivity.state` through `@Published`, so the UI reacts to connection changes without polling.

---

## Backend (Swift / Vapor)

### gRPC server inside the app lifecycle

The gRPC server is integrated into Vapor through `Application.storage` and a `LifecycleHandler`, so there are no singletons:

```swift
enum GRPCConfiguration {
    static func setup(for app: Application) {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        let server = Server.insecure(group: group)
            .withKeepalive(.init(interval: .seconds(10), timeout: .seconds(5), permitWithoutCalls: true))
            .withConnectionIdleTimeout(.seconds(5))
            .withServiceProviders([clientToServerProvider, serverToClientProvider, contactProvider])
            .bind(host: "0.0.0.0", port: 50051)

        app.lifecycle.use(GRPCLifecycleHandler(server: server))
    }
}

struct GRPCLifecycleHandler: LifecycleHandler {
    func willShutdown(_ app: Application) {
        server.whenSuccess { $0.close().whenComplete { _ in } }
    }
}
```

The `ServerToClientProvider` is stored in `app.storage[GRPCStorageKey.self]`, so any controller reaches it via `app.grpcServerToClientProvider`. `numberOfThreads: System.coreCount` lets NIO use every core.

### Idempotent dialogue creation

Before creating a new dialogue, the server looks for an existing one with exactly the same set of participants: a JOIN+IN narrows candidates, then a `Set` equality check confirms the exact match, and the chat plus its members are created atomically in a transaction:

```swift
func findOrCreateChatDialogue(users: [User]) async throws -> (Chat, [ChatMember]) {
    let userIds = try users.map { try $0.requireID() }

    let potentialChats = try await Chat.query(on: db)
        .filter(\.$chatType == .dialogue)
        .join(ChatMember.self, on: \Chat.$id == \ChatMember.$chat.$id)
        .filter(ChatMember.self, \.$user.$id ~~ userIds)
        .all()

    for chat in potentialChats {
        let members = try await ChatMember.query(on: db).filter(\.$chat.$id == chat.requireID()).all()
        if Set(members.map { $0.$user.id }) == Set(userIds) { return (chat, members) }
    }

    return try await db.transaction { tx in
        let newChat = Chat(chatType: .dialogue, title: nil)
        try await newChat.save(on: tx)
        let members = try await users.asyncMap { user in
            let m = try ChatMember(user: user, chat: newChat, role: .member)
            try await m.save(on: tx)
            return m
        }
        return (newChat, members)
    }
}
```

### Full request auditing

An `HttpLoggerMiddleware` writes every HTTP request (except `/asset` and the auth check) into a `http_logs` table: method, URL, headers (as a JSON column), request and response bodies, status, and a nullable `userId` so anonymous requests are logged too:

```swift
final class HttpLoggerMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).flatMap { response in
            let log = HttpLog(
                userId: UUID(uuidString: request.headers["user_id"].first ?? ""),
                method: request.method.rawValue,
                url: request.url.string,
                headers: /* dict */,
                body: request.body.string,
                responseBody: response.body.string,
                statusCode: Int(exactly: response.status.code),
                timestamp: Date()
            )
            return log.save(on: request.db).map { response }
        }
    }
}
```

### Authorization

Phone + flash-call code → JWT (the user enters the last 4 digits of the calling number). An nginx sub-request routes every upstream call through `/auth/check_token_header` on Vapor, which verifies the token and returns `user_id` in a header. The gRPC providers read `user_id` from `context.request.headers`.

---

## The iOS App (SwiftUI, iOS 17)

The app is organized around a handful of focused screens. The tab bar moves between profile, messages, and the camera.

### Home: feed of unread bubbles

A 3×3 grid of unread bubbles, each showing a preview frame from the video, the sender's name, a timestamp, and an unread counter. Below it, the History list shows dialogues with their last text comment and a preview thumbnail.

![The chats home](./media/chats.webp)

### Bubble Player: watching a bubble

A rounded-square video player. Layer objects (stickers and emoji) are rendered on top of the video using the normalized `x / y / scale / rotation` coordinates from Protobuf. A picture-in-picture inset shows the sender's avatar. A toolbar exposes text, reaction, emoji, and playback speed (1.5×); a Comments sheet sits below the player.

![The Bubble player: a received video message with reactions](./media/video-message.webp)

### Comments: the reply thread

A two-sided bubble thread: others on the left, you on the right with a red accent. Replies are supported. As the user scrolls toward the comments, the player collapses into a mini mode and the video keeps playing.

![Comments and reactions on a Bubble](./media/comments.webp)

### Friends: contacts and presence

Two lists: "Bubble friends" (already on the app → a Chat button) and "Add your contacts" (+Add). Sharing invites flow through WhatsApp, TikTok, Instagram, and Facebook, with name search. Friend data arrives over the ContactWithUserActivity gRPC stream.

![Friends already on Bubble Chat, plus contacts to invite](./media/friends.webp)

### Record: capturing a reply bubble

The chat screen: a preview of the other person's latest bubble (rounded player, mute button) and their last-active time. The record button is a red square wrapped in a progress ring, with camera switching and flash. The moment recording starts, the server receives a `CAPTURING` status and the other person sees it in real time through the ContactActivity stream.

![Recording a video Bubble](./media/record.webp)

### Profile

The user's own profile and account surface, reached from the tab bar.

![Profile: Bubbles, friends, reactions](./media/profile.webp)

---

## Media & Video Pipeline

### Sending a bubble: SendPostUseCase

Sending a bubble is a multi-step async pipeline. The UI never waits for the whole chain: `completion()` fires at the right moment so the screen is released while the upload continues in the background.

```
1. INSERT Post(status: .uploading) into GRDB    ← optimistic, visible in UI immediately
2. cropVideoToSquare()                           ← AVMutableComposition, crop to 1:1
3. extractPreviewAndDuration()                   ← first frame at 1s → JPEG
4. completion() fires here                       ← UI is freed while the upload runs
5. POST /media (video + preview) → S3            ← Moya + withCheckedThrowingContinuation
6. UPDATE Post(status: .sending), media.serverId
7. QueueRequestManager.pushQueueRequest()        ← serialize to protobuf, write to GRDB
8. gRPC ClientToServer stream                    ← deliver to the server
```

If the S3 upload fails, `Post.status = .failed` and nothing is sent over gRPC. If the gRPC stream drops, the QueueRequest stays in GRDB and is delivered on reconnect. Files live in Yandex Object Storage (S3) via Soto.

### AVFoundation: cropping and preview frames

**cropVideoToSquare** crops video to a square using `AVMutableComposition` + `AVMutableVideoComposition`:

- Loads the video and audio tracks asynchronously (`async/await`)
- Reads `naturalSize` and `preferredTransform` for correct orientation
- Builds an `AVMutableVideoCompositionLayerInstruction` with a `CGAffineTransform` to center the crop
- Renders square (`renderSize = CGSize(width: cropSize, height: cropSize)`)
- Exports via `AVAssetExportSession` (H.264, medium quality) to a temp directory
- Persists the result through `CacheManager` keyed by `videoClientId`, then deletes the temp file

**extractPreviewAndDuration** generates the preview:

- `AVAssetImageGenerator` with `appliesPreferredTrackTransform = true` to respect orientation
- Takes the frame at the 1-second mark (`CMTime(seconds: 1, preferredTimescale: 600)`)
- Encodes to JPEG (`compressionQuality: 0.8`) and caches it next to the video

### BubbleShape: a custom InsettableShape

The rounded square is not a plain `cornerRadius`. It is described with custom Bézier curves and conforms to `InsettableShape`, which lets one shape serve three jobs at once:

- a clip mask for the video (`.clipShape(BubbleShape())`)
- a stroke track for the player's progress bar (`.stroke(...)`)
- a trim indicator for progress (`.trim(from: 0, to: progress).stroke(...)`)

```swift
struct BubbleShape: InsettableShape {
    func path(in rect: CGRect) -> Path { /* 12 Bézier curves */ }
    func inset(by amount: CGFloat) -> some InsettableShape { ... }
}
```

### Circular progress ring with drag-to-seek

The player's progress ring is built on `BubbleShape().trim()`, so the bar follows the exact outline of the video container. Scrubbing uses a `DragGesture`, converting touch position to an angle with `atan2`:

```swift
func onDrag(value: DragGesture.Value) {
    let vector = CGVector(dx: value.location.x, dy: value.location.y)
    let radians = atan2(vector.dy, vector.dx)
    var angle = radians * 180 / .pi
    if angle < 0 { angle = 360 + angle }

    let targetTime = CMTime(seconds: totalDuration * (angle / 360), preferredTimescale: 600)
    player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
    progress = CGFloat(angle / 360)
}
```

`toleranceBefore: .zero, toleranceAfter: .zero` give frame-accurate seeking; progress updates via `addPeriodicTimeObserver` every 10 ms.

### AVPlayerLayer in SwiftUI

`AVPlayerLayer` has no native SwiftUI equivalent, so it is wrapped in a `UIViewControllerRepresentable` whose `Coordinator` holds the layer reference. A `GeometryReader` feeds the current size, so the layer scales correctly in any container:

```swift
struct CameraPlayerUiKitController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(playerLayer)
        context.coordinator.playerLayer = playerLayer
        return viewController
    }

    func updateUIViewController(_ vc: UIViewController, context: Context) {
        context.coordinator.playerLayer?.frame = CGRect(origin: .zero, size: size)
    }
}
```

---

## Local Persistence (GRDB)

### A 12-table schema with full referential integrity

The schema is defined through `DatabaseMigrator`: versioned, atomic migrations. Every foreign key has an explicit policy:

```swift
// cascade: delete a chat → its posts, members and tracks go too
t.column("chatId").references("chats", onDelete: .cascade)

// setNull: delete media → the post stays, mediaId becomes nil
t.column("mediaId").references("media", onDelete: .setNull)

// uniqueKey: one user appears once per chat
t.uniqueKey(["userId", "chatId"])
```

`foreignKeysEnabled = true` is set on the pool, because SQLite ignores FKs by default. The store uses a `DatabasePool`, giving concurrent reads without blocking writes. Essential when three parallel gRPC streams all touch the local DB at once.

### Cache-first reads

The app reads locally first and only fetches from the server on a miss, then saves the result:

```swift
func findOrFetchChatWithMembers(chatServerId: UUID) async throws -> (Chat, [ChatMember]) {
    if let cached = try await dbPool.read({ db in
        let chat = try Chat.filter(Column("serverId") == chatServerId).fetchOne(db)
        let members = try ChatMember.filter(Column("chatId") == chat?.id).fetchAll(db)
        if let chat, !members.isEmpty { return (chat, members) }
        return nil
    }) { return cached }

    let response = try await WebRequestManager().fetchChat(chatServerId: chatServerId)
    return try await saveChatFromServer(response: response)
}
```

`saveChatFromServer` uses a custom `asyncMap` extension on `Sequence` for sequential async mapping:

```swift
extension Sequence {
    func asyncMap<T>(_ transform: @escaping (Element) async throws -> T) async throws -> [T] {
        var results: [T] = []
        for element in self { try await results.append(transform(element)) }
        return results
    }
}
```

### Polymorphic delivery tracking

A single `DeliveryTrack` row tracks delivery for any entity: post, comment, layer, or reaction. All four ID fields are optional; exactly one is filled:

```swift
struct DeliveryTrack: FetchableRecord, PersistableRecord {
    var postId:     UUID?
    var commentId:  UUID?
    var layerId:    UUID?
    var reactionId: UUID?
    var status:     DeliveryStatus
    var timestamp:  Date
}
```

Vapor mirrors this: when handling a response it deserializes the payload, finds the entity through eager loading (`with(\.$post) { $0.with(\.$chat) }`), creates a `DeliveryTrack`, and enqueues a new `QueueRequest` with the resulting status: an automatic chain of receipts with no explicit request from the client.

### A one-way status machine

Delivery status can only move forward. `canUpdateStatus` guards against regression and is called before every `post.status = newStatus`, so `delivered` can never fall back to `sent`:

```swift
func canUpdateStatus(currentStatus: DeliveryStatus, newStatus: DeliveryStatus) throws {
    let order: [DeliveryStatus] = [.uploading, .sending, .failed, .sent, .delivered, .read, .edited, .deleted]

    guard let cur = order.firstIndex(of: currentStatus),
          let new = order.firstIndex(of: newStatus) else {
        throw AppError.unknown(description: "Invalid status")
    }
    guard new >= cur else {
        throw AppError.database(description: "Bad try to change status to previous")
    }
}
```

### Device contact sync

`updateLocalContacts` syncs the phone's address book with GRDB and the server inside a single `dbPool.write` transaction:

1. Loads all existing contacts in one query into a `Dictionary<UUID, Contact>` for O(1) lookup
2. Streams `CNContactStore` through `enumerateContacts` (no full in-memory load)
3. Upserts each contact: update if present, create if not
4. Filters out the user's own number and nameless contacts
5. Sends new/updated rows without a `serverId` straight to the ContactWithUserActivity gRPC stream
6. Removes contacts from GRDB that no longer exist on the device

---

## App Lifecycle: backgrounding and recovery

The lifecycle is handled at several levels.

**Startup.** `ConfiguratorView.init()` is the single bootstrap point: `GRPCManager.shared.initialize()` brings up the three streams, `UserManager.shared.observeMyData()` loads the current user, and `NotificationManager` requests push permission.

**Background.** `@Environment(\.scenePhase)` tracks `.active` / `.inactive` / `.background`. iOS does not keep TCP alive in the background, so the gRPC connection drops on backgrounding; on return, each provider reconnects on its own via its recursive `startStream()`.

**Safety timer.** `InfiniteLoopManager` runs a Combine `Timer.publish(every: 5.0)` that calls `sendPendingRequests()` every five seconds, a backstop in case the stream recovered but pending requests never flushed:

```swift
class InfiniteLoopManager: ObservableObject {
    private var cancellable: AnyCancellable?

    init() {
        cancellable = Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task(priority: .userInitiated) {
                    QueueRequestManager().sendPendingRequests()
                }
            }
    }
}
```

**Shutdown.** `AppDelegate.applicationWillTerminate` calls `GRPCManager.shared.shutdown()`, closing all providers and `group.syncShutdownGracefully()` on the NIO event-loop group.

**Presence reset on launch.** `allActivitySetOffline()` on `onAppear` resets every `UserActivity.status` to `.offline` in GRDB, clearing stale state before the ContactActivity stream starts delivering fresh presence from the server.

**APNs token.** `AppDelegate.didRegisterForRemoteNotificationsWithDeviceToken` converts the token `Data` to a hex string and sends it to the server. The badge and delivered notifications are cleared on every launch through `UNUserNotificationCenter`.

---

## Results

- A working video-first messenger: capture, layered editing, sending, real-time delivery, reactions, and threaded comments, end to end.
- **Optimistic, offline-capable UI** backed by a 12-table GRDB store with full referential integrity, so the app stays responsive regardless of network state.
- **Exactly-once delivery** of every message through persisted QueueRequests on both client and server, surviving disconnects, backgrounding, and reconnects.
- **One shared domain model** in Protobuf, compiled into both the Vapor server and the iOS client: no duplicated contracts, validated end to end by the Strict-type layer.
- A single-language Swift platform (app + backend) that replaced an earlier Node.js microservice + React Native stack.
