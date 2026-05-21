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
            NSLog("[StreamGate_EXT] ❌ ERROR: Failed to get App Group container. Check your Entitlements!")
            finishBroadcastWithError(NSError(domain: "StreamGateError", code: -1, userInfo: [NSLocalizedDescriptionKey: "App Group container not found."]))
            return
        }
        
        NSLog("[StreamGate_EXT] 🟢 2. App Group Container Found: \(containerURL.path)")
        
        let fileURL = containerURL.appendingPathComponent("\(UUID().uuidString).mp4")
        outputURL = fileURL
        
        do {
            assetWriter = try AVAssetWriter(outputURL: fileURL, fileType: .mp4)
            NSLog("[StreamGate_EXT] 🟢 3. AVAssetWriter Initialized at path: \(fileURL.lastPathComponent)")
        } catch {
            NSLog("[StreamGate_EXT] ❌ ERROR: AVAssetWriter Failed: \(error.localizedDescription)")
            finishBroadcastWithError(error)
        }
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        
        // Only log the very first frame to avoid flooding the console
        if frameCount == 0 {
            NSLog("[StreamGate_EXT] 🟢 4. First sample buffer received. Type: \(sampleBufferType.rawValue)")
        }
        
        guard sampleBufferType == .video, CMSampleBufferDataIsReady(sampleBuffer) else { return }
        frameCount += 1
        
        // 1. Setup Input on first video frame
        if videoInput == nil {
            NSLog("[StreamGate_EXT] 🟢 5. Configuring Video Input dynamically...")
            guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
                NSLog("[StreamGate_EXT] ❌ ERROR: Could not get format description.")
                return
            }
            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
            NSLog("[StreamGate_EXT] 🟢 6. Dynamic Dimensions: \(dimensions.width) x \(dimensions.height)")
            
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: dimensions.width,
                AVVideoHeightKey: dimensions.height
            ]
            
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            input.expectsMediaDataInRealTime = true
            
            if let writer = assetWriter, writer.canAdd(input) {
                writer.add(input)
                videoInput = input
                NSLog("[StreamGate_EXT] 🟢 7. Video Input added successfully.")
            } else {
                NSLog("[StreamGate_EXT] ❌ ERROR: Cannot add Video Input to AssetWriter.")
                return
            }
        }
        
        // 2. Start Writing
        guard let writer = assetWriter, let input = videoInput else { return }
        
        if writer.status == .unknown {
            NSLog("[StreamGate_EXT] 🟢 8. Starting AssetWriter Session...")
            writer.startWriting()
            writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            isRealTimeSessionStarted = true
        }
        
        if writer.status == .writing, input.isReadyForMoreMediaData {
            input.append(sampleBuffer)
        } else if writer.status == .failed {
            NSLog("[StreamGate_EXT] ❌ ERROR: AssetWriter Failed during process! Error: \(String(describing: writer.error?.localizedDescription))")
        }
    }
    
    override func broadcastFinished() {
        NSLog("[StreamGate_EXT] 🟢 9. BROADCAST FINISHED CALLED. Total frames processed: \(frameCount)")
        
        videoInput?.markAsFinished()
        
        guard let writer = assetWriter else {
            NSLog("[StreamGate_EXT] ❌ ERROR: AssetWriter is nil in broadcastFinished")
            return
        }
        
        guard writer.status == .writing else {
            NSLog("[StreamGate_EXT] ❌ ERROR: AssetWriter status is not writing. Status: \(writer.status.rawValue)")
            return
        }
        
        writer.finishWriting { [weak self] in
            guard let self = self, let finalURL = self.outputURL else { return }
            
            NSLog("[StreamGate_EXT] 🟢 10. File finalized at: \(finalURL.absoluteString)")
            
            if let defaults = UserDefaults(suiteName: "group.com.streamgate.broadcast") {
                defaults.set(finalURL.absoluteString, forKey: "recordedVideoURL")
                defaults.synchronize()
                NSLog("[StreamGate_EXT] 🟢 11. SAVED TO USER DEFAULTS SUCCESSFULLY.")
            } else {
                NSLog("[StreamGate_EXT] ❌ ERROR: Failed to initialize UserDefaults with App Group.")
            }
        }
    }
}
