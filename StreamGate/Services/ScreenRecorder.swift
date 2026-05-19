import Foundation
import ReplayKit
import AVFoundation
import Combine

final class ScreenRecorder: ObservableObject {
    
    static let shared = ScreenRecorder()
    
    @Published var isRecording = false
    
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    
    private var outputURL: URL?
    
    // MARK: Start Recording
    
    func startRecording() async throws {
        
        let fileName = UUID().uuidString + ".mp4"
        
        let tempURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(fileName)
        
        outputURL = tempURL
        
        // Remove old file if exists
        
        if FileManager.default.fileExists(atPath: tempURL.path) {
            try FileManager.default.removeItem(at: tempURL)
        }
        
        // Asset Writer
        
        assetWriter = try AVAssetWriter(
            outputURL: tempURL,
            fileType: .mp4
        )
        
        // Better quality settings
        
        let screen = UIScreen.main.bounds
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: screen.width * UIScreen.main.scale,
            AVVideoHeightKey: screen.height * UIScreen.main.scale
        ]
        
        videoInput = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: videoSettings
        )
        
        videoInput?.expectsMediaDataInRealTime = true
        
        if let videoInput {
            assetWriter?.add(videoInput)
        }
        
        let recorder = RPScreenRecorder.shared()
        
        recorder.isMicrophoneEnabled = true
        
        try await recorder.startCapture { [weak self] sampleBuffer,
                                          bufferType,
                                          error in
            
            guard let self else { return }
            
            if let error {
                print(error.localizedDescription)
                return
            }
            
            guard bufferType == .video else {
                return
            }
            
            guard CMSampleBufferDataIsReady(sampleBuffer) else {
                return
            }
            
            if self.assetWriter?.status == .unknown {
                
                self.assetWriter?.startWriting()
                
                self.assetWriter?.startSession(
                    atSourceTime:
                        CMSampleBufferGetPresentationTimeStamp(
                            sampleBuffer
                        )
                )
            }
            
            if self.assetWriter?.status == .writing {
                
                if self.videoInput?.isReadyForMoreMediaData == true {
                    
                    self.videoInput?.append(sampleBuffer)
                }
            }
            
        } completionHandler: { error in
            
            if let error {
                print(error.localizedDescription)
            }
        }
        
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    // MARK: Stop Recording
    
    func stopRecording() async throws -> URL {
        
        let recorder = RPScreenRecorder.shared()
        
        try await recorder.stopCapture()
        
        videoInput?.markAsFinished()
        
        return try await withCheckedThrowingContinuation { continuation in
            
            assetWriter?.finishWriting {
                
                DispatchQueue.main.async {
                    self.isRecording = false
                }
                
                guard let outputURL = self.outputURL else {
                    
                    continuation.resume(
                        throwing: NSError(
                            domain: "No File URL",
                            code: -1
                        )
                    )
                    
                    return
                }
                
                print("Saved Recording:")
                print(outputURL)
                
                continuation.resume(returning: outputURL)
            }
        }
    }
}
