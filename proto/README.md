# Proto: gRPC Contract

This folder holds the Protocol Buffers (proto3) contract shared by the **iOS app** (client)
and the **Vapor backend** (server). It is the single source of truth for the wire format of
the real-time messaging API: both sides generate their models and stubs from these `.proto`
files, so the contract here defines exactly what travels over the network.

The core of the API is **bidirectional gRPC streaming**: long-lived streams over which the
client and server continuously exchange posts, comments, drawing layers, reactions, delivery
receipts, and presence updates.

## Layout

| Folder | Purpose |
| --- | --- |
| `common/` | Shared primitives: identifiers, timestamp, enums. |
| `common_requests/` | Cross-cutting request payloads reused by client and server (delivery status). |
| `entities/` | Domain objects (the "nouns"): post, comment, layer, reaction, reply, media, chat, user, etc. |
| `requests/` | Request envelopes sent over the streams. |
| `responses/` | Response envelopes returned over the streams. |
| `services/` | gRPC `service` / `rpc` definitions: the streaming endpoints. |

## Services

All three services are **bidirectional streams** (`stream ... returns (stream ...)`),
package `services`.

### `ClientToServerStream`: `services/client_to_server.proto`
`rpc ClientStream(stream requests.ClientRequest) returns (stream responses.ServerResponse)`

The client pushes content/actions to the server and receives per-request acknowledgements
plus echoed payloads. This is the main outbound path (the user creating posts, comments,
layers, reactions, and reporting delivery status).

### `ServerToClientStream`: `services/server_to_client.proto`
`rpc ServerStream(stream responses.ClientResponse) returns (stream requests.ServerRequest)`

The inbound path: the server pushes content/actions originating elsewhere (other members)
to the client as `ServerRequest`, and the client returns lightweight `ClientResponse`
acknowledgements.

### `ContactWithUserActivityStream`: `services/contact_with_user_activity.proto`
`rpc ContactUserActivityStream(stream contact_requests.UploadContact) returns (stream contact_responses.ContactWithUserActivity)`

Presence / contacts stream: the client uploads its address-book contacts
(`UploadContact`), and the server streams back, for matched users, their public profile
plus live activity (`ContactWithUserActivity` = `PublicUserEntity` + `PublicUserActivityEntity`).

## Request / response envelopes

The send/receive envelopes mirror each other and carry a `oneof payload` selecting the
concrete entity, keyed by a `common.RequestId`:

- **`requests.ClientRequest`**: `request_id` + one of `PostEntity`, `CommentEntity`,
  `LayerEntity`, `ReactionEntity`, or `DeliveryStatusPayload`.
- **`requests.ServerRequest`**: symmetric `receive` variant pushed by the server.
- **`responses.ServerResponse`**: `request_id`, `success`, `error_message` + the echoed
  `oneof payload`.
- **`responses.ClientResponse`**. Lightweight ack: `request_id`, `success`, `error_message`.
- **`common_requests.DeliveryStatusPayload`**: delivery/read tracking across chat, member,
  post, comment, layer, reaction, with a `DeliveryStatus` and `Timestamp`.

## Entities (`entities/`)

- **`PostEntity`**: a post (`PostType`: `BUBBLE` / `FRAME` / `TOPIC`) with optional
  `MediaEntity`, title, description, and `ReplyEntity`.
- **`CommentEntity`**: a comment attached to a post, optionally a reply.
- **`LayerEntity`**: a positioned overlay on a post (`LayerType`: `TEXT` / `GIF` /
  `STICKER`) with transform (x, y, scale, rotation) and a `oneof` of
  `TextAttributes` / `GifAttributes` / `StickerAttributes`.
- **`ReactionEntity`**: an emoji reaction on a post or comment (`ChatEntityType`).
- **`ReplyEntity`**: reference to the entity being replied to.
- **`MediaEntity`**: media reference (`MediaType`: `VIDEO` / `IMAGE`) with duration.
- **`ChatEntity`**: a chat (`ChatType`: `DIALOGUE` / `GROUP`) with title.
- **`PublicChatMemberEntity`**: a chat member with `MemberRole` (`OWNER` / `MEMBER`).
- **`PublicUserEntity`**: public user profile (name, avatar, phone).
- **`PublicUserActivityEntity`**. Presence: `UserStatus`
  (`ONLINE` / `OFFLINE` / `TYPING` / `ACTIVE` / `CAPTURING`) + last-active timestamp.

## Common (`common/`)

- **`identifiers.proto`**: ID messages (`RequestId`, `UserId`, `ChatId`, `PostId`,
  `CommentId`, `LayerId`, `ReactionId`, `MediaId`, `ChatMemberId`, `ContactId`,
  `DeliveryTrackId`, `ReplyToId`, `UserActivityId`). Most carry both a `server` and a
  `client` value to reconcile optimistic client-generated IDs with server-assigned ones.
- **`timestamp.proto`**: `Timestamp` (ISO 8601 string).
- **`enums.proto`**: `DeliveryStatus`, `ChatType`, `ChatEntityType`, `LayerType`,
  `UserStatus`, `MediaType`, `MemberRole`, `PostType`.
