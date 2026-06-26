//
//  AssetController.swift
//  BubbleBackendVapor
//
//  Created by polezhaev_aleksandr on 28.09.2024.
//

import Fluent
import JWTKit
import SotoS3
import Vapor

struct AssetController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let assetRoutes = routes.grouped("asset")

        assetRoutes.grouped(UserIdMiddleware())
            .post("media", "video-and-preview", use: uploadVideoAndPreview)
        assetRoutes.get("download", ":mediaType", ":serverId", use: downloadMedia)
        assetRoutes.get("media", ":mediaServerId", use: getPublicMedia)
    }
}

// MARK: - Upload video

extension AssetController {
    struct MultipartFormData: Content {
        var clientId: UUID
        var video: File
        var preview: File
        var duration: Int
    }

    @Sendable
    func uploadVideoAndPreview(req: Request) async throws -> Media {
        let data = try req.content.decode(MultipartFormData.self)

        guard let user = try await User.find(req.userId, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }

        let mediaId = UUID()

        let putVideoRequest = S3.PutObjectRequest(
            body: AWSPayload.byteBuffer(ByteBuffer(bytes: data.video.data.readableBytesView)),
            bucket: Environment.get("S3_VIDEO_BUCKET") ?? "video",
            contentType: "video/mp4",
            key: mediaId.uuidString + ".mp4"
        )

        let putPreviewRequest = S3.PutObjectRequest(
            body: AWSPayload.byteBuffer(ByteBuffer(bytes: data.preview.data.readableBytesView)),
            bucket: Environment.get("S3_PREVIEW_BUCKET") ?? "preview",
            contentType: "image/jpg",
            key: mediaId.uuidString + ".jpg"
        )

        return try await req.db.transaction { transaction in
            do {
                let s3 = req.application.s3

                // Asynchronous upload to S3
                async let videoUpload = s3.putObject(putVideoRequest)
                async let previewUpload = s3.putObject(putPreviewRequest)

                // Wait for the uploads to finish
                _ = try await (videoUpload, previewUpload)

                // Create the video object
                let newMedia = try Media(id: mediaId,
                                         clientId: data.clientId,
                                         user: user,
                                         mediaType: .video,
                                         duration: data.duration)

                // Save the object within a transaction
                try await newMedia.save(on: transaction)

                return newMedia
            } catch {
                throw Abort(.internalServerError, reason: "Failed to upload video or preview to S3:  \(String(reflecting: error))")
            }
        }
    }
}

// MARK: - Download video/preview

extension AssetController {
    @Sendable
    func downloadMedia(req: Request) async throws -> Response {
        guard let mediaType = try MediaType(rawValue: req.parameters.require("mediaType")) else {
            throw Abort(.badRequest, reason: "Invalid media type")
        }
        guard let mediaServerId = try UUID(uuidString: req.parameters.require("serverId")) else {
            throw Abort(.badRequest, reason: "Invalid media id")
        }

        var bucketName: String {
            switch mediaType {
            case .video:
                Environment.get("S3_VIDEO_BUCKET") ?? "video"
            case .image:
                Environment.get("S3_PREVIEW_BUCKET") ?? "preview"
            }
        }

        var key: String {
            switch mediaType {
            case .video:
                mediaServerId.uuidString + ".mp4"
            case .image:
                mediaServerId.uuidString + ".jpg"
            }
        }

        // Configure the request to fetch the file from S3
        let getObjectRequest = S3.GetObjectRequest(
            bucket: bucketName,
            key: key
        )

        let response = try await req.application.s3.getObject(getObjectRequest)

        // Verify that the file was found
        guard let body = response.body else {
            throw Abort(.notFound, reason: "File not found in S3 bucket.")
        }

        guard let contentType = response.contentType else {
            throw Abort(.notFound, reason: "Invalid content type")
        }

        guard let buffer = body.asByteBuffer() else {
            throw Abort(.notFound, reason: "Error while making ByteBuffer from s3 body")
        }

        // Convert the ByteBuffer into the Response body
        return Response(
            status: .ok,
            headers: ["Content-Type": contentType],
            body: .init(buffer: buffer)
        )
    }
}

extension PublicMedia: Content {}

extension AssetController {
    @Sendable
    func getPublicMedia(req: Request) async throws -> PublicMedia {
        // Extract serverId from the route parameters
        guard let mediaId = req.parameters.get("mediaServerId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid media serverId")
        }

        // Look up the media by serverId
        guard let media = try await Media.find(mediaId, on: req.db) else {
            throw Abort(.notFound, reason: "Media not found")
        }

        // Build the public object
        return try media.asPublic()
    }
}
