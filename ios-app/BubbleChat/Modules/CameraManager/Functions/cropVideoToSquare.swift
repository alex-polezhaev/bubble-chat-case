//
//  cropVideoToSquare.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 10.09.2024.
//

import AVFoundation
import AVKit
import Foundation

func cropVideoToSquare(inputURL: URL, videoClientId: UUID) async throws -> URL {
    // Check whether the video is already cropped
    if inputURL.lastPathComponent.contains("_cropped") {
        print("Video is already cropped: \(inputURL)")
        return inputURL
    }

    let asset = AVAsset(url: inputURL)
    let composition = AVMutableComposition()

    // Load the video track
    let videoTracks = try await asset.loadTracks(withMediaType: .video)
    guard let videoTrack = videoTracks.first else {
        throw NSError(domain: "VideoTrackNotFound", code: -1, userInfo: nil)
    }

    // Load the audio track, if present
    let audioTracks = try await asset.loadTracks(withMediaType: .audio)
    if let audioTrack = audioTracks.first {
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        try compositionAudioTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: await asset.load(.duration)), of: audioTrack, at: .zero)
    }

    // Load properties asynchronously (iOS 16+)
    let videoDuration = try await asset.load(.duration)
    let videoSize = try await videoTrack.load(.naturalSize)
    let videoTransform = try await videoTrack.load(.preferredTransform)

    // Calculate the crop frame size: a square based on the smaller side
    let cropSize = min(videoSize.width, videoSize.height)

    // Create the composition track
    guard let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
        throw NSError(domain: "CompositionTrackError", code: -1, userInfo: nil)
    }

    // Add the video track to the composition track
    try compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoDuration), of: videoTrack, at: .zero)

    // Calculate the correct transform to center the video
    let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)

    // Rotate the video if needed, based on preferredTransform
    var finalTransform = videoTransform

    // Apply the transform with an offset
    finalTransform = finalTransform.concatenating(CGAffineTransform(translationX: 0, y: -280))
    videoLayerInstruction.setTransform(finalTransform, at: .zero)

    // Create the instruction for the video composition
    let videoCompositionInstruction = AVMutableVideoCompositionInstruction()
    videoCompositionInstruction.timeRange = CMTimeRange(start: .zero, duration: videoDuration)
    videoCompositionInstruction.layerInstructions = [videoLayerInstruction]

    // Create the video composition with a square size
    let videoComposition = AVMutableVideoComposition()
    videoComposition.renderSize = CGSize(width: cropSize, height: cropSize)
    videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
    videoComposition.instructions = [videoCompositionInstruction]

    // Generate the path via CacheManager
    guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality) else {
        throw NSError(domain: "CropVideoError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session."])
    }

    // Export the video to a temporary file
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
    exportSession.videoComposition = videoComposition
    exportSession.outputURL = tempURL
    exportSession.outputFileType = .mp4

    await exportSession.export()

    // Check the export status
    if exportSession.status == .completed {
        // Save the file via CacheManager
        let fileURL = try CacheManager.shared.save(
            data: Data(contentsOf: tempURL),
            filename: "\(videoClientId.uuidString).mp4",
            category: "videos"
        )
        // Remove the temporary file
        try FileManager.default.removeItem(at: tempURL)
        print("crop saved to \(fileURL)")

        return fileURL
    } else if let exportError = exportSession.error {
        throw exportError
    } else {
        throw NSError(domain: "CropVideoError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Unknown export error."])
    }
}
