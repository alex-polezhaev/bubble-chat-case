//
//  extractPreviewAndDuration.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 20.10.2024.
//

import AVFoundation
import Foundation
import UIKit

func extractPreviewAndDuration(from videoUrl: URL, videoClientId: UUID) async throws -> (previewUrl: URL, duration: Int) {
    let asset = AVAsset(url: videoUrl)

    // Get the video duration using load(.duration)
    let durationTime = try await asset.load(.duration)
    let duration = Int(CMTimeGetSeconds(durationTime))

    // Generate a preview (the first frame)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    let time = CMTime(seconds: 1, preferredTimescale: 600) // Take the frame at the first second

    let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
    let previewImage = UIImage(cgImage: cgImage)

    guard let jpegData = previewImage.jpegData(compressionQuality: 0.8) else {
        throw NSError(domain: "ExtractPreviewError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data."])
    }
    let previewUrl = try CacheManager.shared.save(data: jpegData, filename: "\(videoClientId.uuidString).jpg", category: "images")

    print("preview saved to \(previewUrl)")

    return (previewUrl, duration)
}
