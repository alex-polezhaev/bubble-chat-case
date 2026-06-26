//
//  CameraManager.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 20.10.2024.
//

import AVFoundation
import AVKit
import SwiftUI

// CameraManager as Singleton
final class CameraManager: NSObject, ObservableObject {
    static let shared = CameraManager()

    var captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let movieOutput = AVCaptureMovieFileOutput()

    var currentCameraPosition: AVCaptureDevice.Position = .back // Current camera (rear by default)

    private var currentInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?

    @Published var recordedVideoURL: URL? // URL for the recorded video
    @Published var isConfigured: Bool = false // Camera readiness flag
    @Published var isRunning: Bool = false // Flag to track the camera state (running or not)

    // Preview layer for the camera
    @Published var previewLayer: AVCaptureVideoPreviewLayer?

    // Private initializer for Singleton
    override private init() {
        super.init()
    }

    // Setup camera with optimized settings
    func setupCamera(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    // Set maximum quality: 4K or Full HD
                    self.captureSession.sessionPreset = .hd1280x720 // Use .hd4K3840x2160 for 4K

                    self.configureSession(for: self.currentCameraPosition)
                    self.isConfigured = true // Camera is ready to use
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }

    // Configure camera session with video and audio
    private func configureSession(for position: AVCaptureDevice.Position) {
        captureSession.beginConfiguration()

        DispatchQueue.main.async {
            self.isConfigured = false // Set to false until the camera is configured
        }

        // Remove all existing inputs
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }

        // Get camera for the required position (front/back)
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let videoInput = try? AVCaptureDeviceInput(device: camera)
        else {
            print("Error: Unable to access the camera.")
            return
        }

        // Add the new video input
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
            currentInput = videoInput
            currentCameraPosition = position // Update the current camera position
        }

        // Add audio input (microphone) if not already added
        if let microphone = AVCaptureDevice.default(for: .audio) {
            do {
                let audioInput = try AVCaptureDeviceInput(device: microphone)
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                    self.audioInput = audioInput
                }
            } catch {
                print("Error: Unable to access the microphone.")
            }
        }

        // Add video output if not already added
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        // Add movie file output for video recording
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)

            // Set only the codec for video recording (H.264 only)
            let connection = movieOutput.connection(with: .video)
            movieOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.h264], for: connection!)
        }

        // Enable video stabilization if supported
        if let connection = videoOutput.connection(with: .video), connection.isVideoStabilizationSupported {
            connection.preferredVideoStabilizationMode = .standard // Enable stabilization
            print("Stabilization mode set to: \(connection.preferredVideoStabilizationMode.rawValue)")
        } else {
            print("Stabilization not supported on this device or configuration.")
        }

        captureSession.commitConfiguration()

        // Setup the preview layer
        setupPreviewLayer()
    }

    // Set up the preview layer for the camera session
    private func setupPreviewLayer() {
        DispatchQueue.main.async {
            // Clear previewLayer before configuring the new camera
            self.previewLayer?.session = nil
            self.previewLayer?.removeFromSuperlayer()

            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer?.videoGravity = .resizeAspectFill

            DispatchQueue.main.async {
                self.isConfigured = true
            }
        }
    }

    // Start camera session (on background thread)
    func startSession() {
        guard isConfigured else {
            print("Camera is not configured yet.")
            setupCamera { _ in
                self.startSession()
            }
            return
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.isRunning = true
                }
            }
        }
    }

    // Stop camera session (on background thread)
    func stopSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                DispatchQueue.main.async {
                    self.isRunning = false // Camera stopped

                    // Clear previewLayer when the session stops
                    self.setupPreviewLayer()

                    print("Camera session stopped.")
                }
            }
        }
    }

    // Switch between front and back cameras
    func switchCamera() {
        let newPosition: AVCaptureDevice.Position = currentCameraPosition == .back ? .front : .back

        isConfigured = false
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.configureSession(for: newPosition)
        }
    }

    func startRecording() {
        guard isConfigured else {
            print("Camera is not configured yet.")
            return
        }

        let outputDirectory = FileManager.default.temporaryDirectory
        let outputFileURL = outputDirectory.appendingPathComponent("\(UUID().uuidString).mov")

        movieOutput.startRecording(to: outputFileURL, recordingDelegate: self)
        print("Recording started")
    }

    // Stop recording video
    func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            print("Recording stopped")
        }
    }
}

// Extend CameraManager to conform to AVCaptureFileOutputRecordingDelegate
extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from _: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error)")
            return
        }
        recordedVideoURL = outputFileURL
        print("Video saved at: \(outputFileURL)")
    }
}

extension CameraManager {
    func toggleFlash() {
        guard currentCameraPosition == .back else {
            print("Flash is available only for the rear camera")
            return
        }

        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), backCamera.hasTorch else {
            print("The rear camera does not support flash")
            return
        }
        do {
            try backCamera.lockForConfiguration()

            if backCamera.torchMode == .on {
                backCamera.torchMode = .off
            } else {
                try backCamera.setTorchModeOn(level: 1.0) // Turn on the flash at full power
            }

            backCamera.unlockForConfiguration()
        } catch {
            print("Failed to toggle the flash: \(error)")
        }
    }
}
