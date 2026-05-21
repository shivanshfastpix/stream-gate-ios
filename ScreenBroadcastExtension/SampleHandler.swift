//import ReplayKit
//import AVFoundation
// 
//class SampleHandler: RPBroadcastSampleHandler {
//    private var assetWriter: AVAssetWriter?
//    private var videoInput: AVAssetWriterInput?
//    private var outputURL: URL?
//    private var isRealTimeSessionStarted = false
//    private var frameCount = 0
//    
//    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
//        
//        // === SENTINEL: proves the extension was launched ===
//         let suiteName = "group.com.streamgate.broadcast"
//         if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) {
//             let sentinel = container.appendingPathComponent("EXTENSION_RAN.txt")
//             try? "ran at \(Date())".write(to: sentinel, atomically: true, encoding: .utf8)
//         }
//         UserDefaults(suiteName: suiteName)?.set(Date(), forKey: "extensionLastRan")
//         // === END SENTINEL ===
//        
//        NSLog("[StreamGate_EXT] 🟢 1. BROADCAST STARTED CALLED")
//        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.streamgate.broadcast") else {
//            NSLog("[StreamGate_EXT] ❌ ERROR: Failed to get App Group container.")
//            finishBroadcastWithError(NSError(domain: "StreamGateError", code: -1, userInfo: [NSLocalizedDescriptionKey: "App Group container not found."]))
//            return
//        }
//        // Generate file name
////        let fileURL = containerURL.appendingPathComponent("\(UUID().uuidString).mp4")
////        outputURL = fileURL
//        
//        let fileURL = containerURL.appendingPathComponent("\(UUID().uuidString).mp4.tmp")
//        outputURL = fileURL
//        
//        do {
//            assetWriter = try AVAssetWriter(outputURL: fileURL, fileType: .mp4)
//            NSLog("[StreamGate_EXT] 🟢 3. AVAssetWriter Initialized: \(fileURL.lastPathComponent)")
//        } catch {
//            NSLog("[StreamGate_EXT] ❌ ERROR: AVAssetWriter Failed: \(error.localizedDescription)")
//            finishBroadcastWithError(error)
//        }
//    }
//    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
//        guard sampleBufferType == .video, CMSampleBufferDataIsReady(sampleBuffer) else { return }
//        frameCount += 1
//        if videoInput == nil {
//            guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
//            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
//            // FIX 1: Explicit compression properties are required for H.264 recording
//            let videoSettings: [String: Any] = [
//                AVVideoCodecKey: AVVideoCodecType.h264,
//                AVVideoWidthKey: dimensions.width,
//                AVVideoHeightKey: dimensions.height,
//                AVVideoCompressionPropertiesKey: [
//                    AVVideoAverageBitRateKey: 2_000_000, // 2 Mbps keeps memory footprint low
//                    AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel
//                ]
//            ]
//            let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
//            input.expectsMediaDataInRealTime = true
//            if let writer = assetWriter, writer.canAdd(input) {
//                writer.add(input)
//                videoInput = input
//            } else {
//                return
//            }
//        }
//        guard let writer = assetWriter, let input = videoInput else { return }
//        if writer.status == .unknown {
//            writer.startWriting()
//            writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
//            isRealTimeSessionStarted = true
//        }
//        if writer.status == .writing, input.isReadyForMoreMediaData {
//            input.append(sampleBuffer)
//        }
//    }
//    
//    override func broadcastFinished() {
//
//        NSLog("[StreamGate_EXT] 🟢 9. BROADCAST FINISHED CALLED.")
//     
//        guard let writer = assetWriter, writer.status == .writing else {
//
//            NSLog("[StreamGate_EXT] ⚠️ Writer not writing. Status: \(assetWriter?.status.rawValue ?? -1)")
//
//            return
//
//        }
//     
//        videoInput?.markAsFinished()
//     
//        let semaphore = DispatchSemaphore(value: 0)
//     
//        writer.finishWriting { [weak self] in
//
//            defer { semaphore.signal() }
//
//            guard let self = self, let tmpURL = self.outputURL else { return }
//     
//            // Rename .tmp → .mp4 so the main app only ever sees fully-written files
//
//            let finalURL = tmpURL.deletingPathExtension().appendingPathExtension("mp4")
//
//            try? FileManager.default.removeItem(at: finalURL)
//
//            do {
//
//                try FileManager.default.moveItem(at: tmpURL, to: finalURL)
//
//            } catch {
//
//                NSLog("[StreamGate_EXT] ❌ rename failed: \(error)")
//
//                return
//
//            }
//     
//            if let defaults = UserDefaults(suiteName: "group.com.streamgate.broadcast") {
//
//                defaults.set(finalURL.path, forKey: "recordedVideoURL")
//
//            }
//
//            NSLog("[StreamGate_EXT] 🟢 finalized at \(finalURL.path)")
//
//        }
//     
//        // Block until writer flushes (or 5s safety cap)
//
//        _ = semaphore.wait(timeout: .now() + 5)
//
//    }
//     
//    
////    override func broadcastFinished() {
////        NSLog("[StreamGate_EXT] 🟢 9. BROADCAST FINISHED CALLED.")
////        
////        videoInput?.markAsFinished()
////        
////        guard let writer = assetWriter else { return }
////        
////        if writer.status == .writing {
////            writer.finishWriting { [weak self] in
////                guard let self = self, let finalURL = self.outputURL else { return }
////                
////                NSLog("[StreamGate_EXT] 🟢 10. File finalized at: \(finalURL.absoluteString)")
////                
////                if let defaults = UserDefaults(suiteName: "group.com.streamgate.broadcast") {
////                    // Save the local file PATH string safely without blocking the thread
////                    defaults.set(finalURL.path, forKey: "recordedVideoURL")
////                    defaults.synchronize()
////                    NSLog("[StreamGate_EXT] 🟢 11. SAVED TO USER DEFAULTS SUCCESSFULLY.")
////                }
////            }
////        } else {
////            NSLog("[StreamGate_EXT] ⚠️ Writer was not in a writing state. Status: \(writer.status.rawValue)")
////        }
////    }
//    
//    
//    
////    override func broadcastFinished() {
////        NSLog("[StreamGate_EXT] 🟢 9. BROADCAST FINISHED CALLED.")
////        videoInput?.markAsFinished()
////        guard let writer = assetWriter else { return }
////        // FIX 2: Use a DispatchGroup to force the extension to stay alive until writing finishes
////        let group = DispatchGroup()
////        group.enter()
////        if writer.status == .writing {
////            writer.finishWriting { [weak self] in
////                guard let self = self, let finalURL = self.outputURL else {
////                    group.leave()
////                    return
////                }
////                NSLog("[StreamGate_EXT] 🟢 10. File finalized at: \(finalURL.absoluteString)")
////                if let defaults = UserDefaults(suiteName: "group.com.streamgate.broadcast") {
////                    // FIX 3: Save the local file PATH string, not the absolute URL string
////                    defaults.set(finalURL.path, forKey: "recordedVideoURL")
////                    defaults.synchronize()
////                    NSLog("[StreamGate_EXT] 🟢 11. SAVED TO USER DEFAULTS.")
////                }
////                group.leave()
////            }
////        } else {
////            group.leave()
////        }
////        // Block the main thread for up to 5 seconds to guarantee the save finishes
////        _ = group.wait(timeout: .now() + 5.0)
////    }
//}


import ReplayKit
import AVFoundation
 
class SampleHandler: RPBroadcastSampleHandler {
    private static let suiteName = "group.com.streamgate.broadcast"
 
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var tmpURL: URL?           // where AVAssetWriter writes (extension temp dir)
    private var finalURL: URL?         // where main app reads (App Group container)
    private var frameCount = 0
    private var appendedCount = 0
    private var sessionStarted = false
 
    private static func container() -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)
    }
 
    private static func writeStage(_ stage: String, _ detail: String = "") {
        guard let dir = container() else { return }
        let line = "[\(Date())] \(stage) \(detail)\n"
        let url = dir.appendingPathComponent("LIFECYCLE.log")
        if let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            handle.write(line.data(using: .utf8) ?? Data())
            try? handle.close()
        } else {
            try? line.write(to: url, atomically: true, encoding: .utf8)
        }
    }
 
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        if let dir = Self.container() {
            try? FileManager.default.removeItem(at: dir.appendingPathComponent("LIFECYCLE.log"))
        }
        Self.writeStage("1_STARTED")
 
        let name = "\(UUID().uuidString).mp4"
        // Write to extension's temp dir — AVAssetWriter is happy here.
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
        tmpURL = tmp
        // Where we'll move it after finishWriting succeeds.
        finalURL = Self.container()?.appendingPathComponent(name)
 
        Self.writeStage("2_TMP_URL", tmp.path)
 
        // Belt-and-braces: AVAssetWriter refuses to write if the file already exists.
        try? FileManager.default.removeItem(at: tmp)
 
        do {
            assetWriter = try AVAssetWriter(outputURL: tmp, fileType: .mp4)
            Self.writeStage("3_WRITER_INIT_OK")
        } catch {
            Self.writeStage("ERR_WRITER_INIT", error.localizedDescription)
            finishBroadcastWithError(error)
        }
    }
 
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with type: RPSampleBufferType) {
        guard type == .video, CMSampleBufferDataIsReady(sampleBuffer) else { return }
        frameCount += 1
        if frameCount == 1 { Self.writeStage("4_FIRST_FRAME") }
 
        if videoInput == nil {
            guard let fmt = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
            let dim = CMVideoFormatDescriptionGetDimensions(fmt)
            // Round to nearest multiple of 16 for H.264 safety.
            let w = Int(dim.width) - (Int(dim.width) % 16)
            let h = Int(dim.height) - (Int(dim.height) % 16)
 
            let settings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: w,
                AVVideoHeightKey: h,
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: 2_000_000,
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel
                ]
            ]
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            input.expectsMediaDataInRealTime = true
            if let writer = assetWriter, writer.canAdd(input) {
                writer.add(input)
                videoInput = input
                Self.writeStage("5_INPUT_ADDED", "\(w)x\(h) (raw \(dim.width)x\(dim.height))")
            } else {
                Self.writeStage("ERR_CANT_ADD_INPUT")
                return
            }
        }
 
        guard let writer = assetWriter, let input = videoInput else { return }
 
        if writer.status == .unknown {
            let ok = writer.startWriting()
            Self.writeStage("6_START_WRITING", "returned=\(ok) status=\(writer.status.rawValue) err=\(String(describing: writer.error))")
            if !ok { return }
            writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            sessionStarted = true
            Self.writeStage("7_SESSION_STARTED", "status=\(writer.status.rawValue)")
        }
 
        if writer.status == .writing, input.isReadyForMoreMediaData {
            input.append(sampleBuffer)
            appendedCount += 1
            if appendedCount == 1 { Self.writeStage("8_FIRST_APPEND_OK") }
        }
    }
 
    override func broadcastFinished() {
        Self.writeStage("9_FINISHED_CALLED", "frames=\(frameCount) appended=\(appendedCount)")
 
        guard let writer = assetWriter, writer.status == .writing else {
            Self.writeStage("ERR_NOT_WRITING_AT_FINISH", "status=\(assetWriter?.status.rawValue ?? -1) err=\(String(describing: assetWriter?.error))")
            return
        }
 
        videoInput?.markAsFinished()
 
        let semaphore = DispatchSemaphore(value: 0)
        writer.finishWriting { [weak self] in
            defer { semaphore.signal() }
            guard let self = self, let tmp = self.tmpURL, let final = self.finalURL else { return }
            Self.writeStage("10_FINISH_WRITING_DONE", "status=\(writer.status.rawValue) err=\(String(describing: writer.error))")
 
            // Move from extension temp → App Group so the main app can see it.
            try? FileManager.default.removeItem(at: final)
            do {
                try FileManager.default.moveItem(at: tmp, to: final)
                Self.writeStage("11_MOVED_TO_GROUP", final.path)
                UserDefaults(suiteName: Self.suiteName)?.set(final.path, forKey: "recordedVideoURL")
                Self.writeStage("12_USERDEFAULTS_SET")
            } catch {
                Self.writeStage("ERR_MOVE_FAILED", error.localizedDescription)
            }
        }
        _ = semaphore.wait(timeout: .now() + 5)
        Self.writeStage("13_AFTER_WAIT")
    }
}
