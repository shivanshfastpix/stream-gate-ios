import ReplayKit
import AVFoundation
 
class SampleHandler: RPBroadcastSampleHandler {
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var outputURL: URL?
    private var isRealTimeSessionStarted = false
    private var frameCount = 0
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        NSLog("[StreamGate_EXT] 🟢 1. BROADCAST STARTED CALLED")
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.streamgate.broadcast") else {
            NSLog("[StreamGate_EXT] ❌ ERROR: Failed to get App Group container.")
            finishBroadcastWithError(NSError(domain: "StreamGateError", code: -1, userInfo: [NSLocalizedDescriptionKey: "App Group container not found."]))
            return
        }
        // Generate file name
        let fileURL = containerURL.appendingPathComponent("\(UUID().uuidString).mp4")
        outputURL = fileURL
        do {
            assetWriter = try AVAssetWriter(outputURL: fileURL, fileType: .mp4)
            NSLog("[StreamGate_EXT] 🟢 3. AVAssetWriter Initialized: \(fileURL.lastPathComponent)")
        } catch {
            NSLog("[StreamGate_EXT] ❌ ERROR: AVAssetWriter Failed: \(error.localizedDescription)")
            finishBroadcastWithError(error)
        }
    }
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video, CMSampleBufferDataIsReady(sampleBuffer) else { return }
        frameCount += 1
        if videoInput == nil {
            guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
            // FIX 1: Explicit compression properties are required for H.264 recording
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: dimensions.width,
                AVVideoHeightKey: dimensions.height,
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: 2_000_000, // 2 Mbps keeps memory footprint low
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel
                ]
            ]
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            input.expectsMediaDataInRealTime = true
            if let writer = assetWriter, writer.canAdd(input) {
                writer.add(input)
                videoInput = input
            } else {
                return
            }
        }
        guard let writer = assetWriter, let input = videoInput else { return }
        if writer.status == .unknown {
            writer.startWriting()
            writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            isRealTimeSessionStarted = true
        }
        if writer.status == .writing, input.isReadyForMoreMediaData {
            input.append(sampleBuffer)
        }
    }
    
    override func broadcastFinished() {
        NSLog("[StreamGate_EXT] 🟢 9. BROADCAST FINISHED CALLED.")
        
        videoInput?.markAsFinished()
        
        guard let writer = assetWriter else { return }
        
        if writer.status == .writing {
            writer.finishWriting { [weak self] in
                guard let self = self, let finalURL = self.outputURL else { return }
                
                NSLog("[StreamGate_EXT] 🟢 10. File finalized at: \(finalURL.absoluteString)")
                
                if let defaults = UserDefaults(suiteName: "group.com.streamgate.broadcast") {
                    // Save the local file PATH string safely without blocking the thread
                    defaults.set(finalURL.path, forKey: "recordedVideoURL")
                    defaults.synchronize()
                    NSLog("[StreamGate_EXT] 🟢 11. SAVED TO USER DEFAULTS SUCCESSFULLY.")
                }
            }
        } else {
            NSLog("[StreamGate_EXT] ⚠️ Writer was not in a writing state. Status: \(writer.status.rawValue)")
        }
    }
    
//    override func broadcastFinished() {
//        NSLog("[StreamGate_EXT] 🟢 9. BROADCAST FINISHED CALLED.")
//        videoInput?.markAsFinished()
//        guard let writer = assetWriter else { return }
//        // FIX 2: Use a DispatchGroup to force the extension to stay alive until writing finishes
//        let group = DispatchGroup()
//        group.enter()
//        if writer.status == .writing {
//            writer.finishWriting { [weak self] in
//                guard let self = self, let finalURL = self.outputURL else {
//                    group.leave()
//                    return
//                }
//                NSLog("[StreamGate_EXT] 🟢 10. File finalized at: \(finalURL.absoluteString)")
//                if let defaults = UserDefaults(suiteName: "group.com.streamgate.broadcast") {
//                    // FIX 3: Save the local file PATH string, not the absolute URL string
//                    defaults.set(finalURL.path, forKey: "recordedVideoURL")
//                    defaults.synchronize()
//                    NSLog("[StreamGate_EXT] 🟢 11. SAVED TO USER DEFAULTS.")
//                }
//                group.leave()
//            }
//        } else {
//            group.leave()
//        }
//        // Block the main thread for up to 5 seconds to guarantee the save finishes
//        _ = group.wait(timeout: .now() + 5.0)
//    }
}
