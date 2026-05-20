import ReplayKit
import AVFoundation

class SampleHandler: RPBroadcastSampleHandler {
    
    private var assetWriter: AVAssetWriter?
    
    private var videoInput: AVAssetWriterInput?
    
    private var outputURL: URL?
    
    // MARK: Broadcast Started
    
    override func broadcastStarted(
        withSetupInfo setupInfo:
        [String : NSObject]?
    ) {
        NSLog("Broadcast Started")
        do {
            
            // Shared App Group Container
            
            guard let containerURL =
                    FileManager.default.containerURL(
                        forSecurityApplicationGroupIdentifier:
                            "group.com.streamgate.broadcast"
                    ) else {
                
                finishBroadcastWithError(
                    NSError(
                        domain: "App Group Error",
                        code: -1
                    )
                )
                
                return
            }
            
            let fileName =
            UUID().uuidString + ".mp4"
            
            let fileURL =
            containerURL
                .appendingPathComponent(fileName)
            
            outputURL = fileURL
            
            // Remove Existing
            
            if FileManager.default.fileExists(
                atPath: fileURL.path
            ) {
                try FileManager.default.removeItem(
                    at: fileURL
                )
            }
            
            // Asset Writer
            
            assetWriter = try AVAssetWriter(
                outputURL: fileURL,
                fileType: .mp4
            )
            
//            let screen = UIScreen.main.bounds
            
            let screen = CGRect(
                x: 0,
                y: 0,
                width: 390,
                height: 844
            )
            
            let settings: [String: Any] = [

                AVVideoCodecKey:
                    AVVideoCodecType.h264,

                AVVideoWidthKey:
                    screen.width * 3.0,

                AVVideoHeightKey:
                    screen.height * 3.0
            ]
           
            
//            let settings: [String: Any] = [
//                
//                AVVideoCodecKey:
//                    AVVideoCodecType.h264,
//                
//                AVVideoWidthKey:
//                    screen.width * UIScreen.main.scale,
//                
//                AVVideoHeightKey:
//                    screen.height * UIScreen.main.scale
//            ]
            
            videoInput = AVAssetWriterInput(
                mediaType: .video,
                outputSettings: settings
            )
            
            videoInput?.expectsMediaDataInRealTime =
            true
            
            if let videoInput {
                assetWriter?.add(videoInput)
            }
            
            print("Broadcast Started")
            
        } catch {
            
            finishBroadcastWithError(error)
        }
    }
    
    
    
    // MARK: Process Buffers
    
    override func processSampleBuffer(
        _ sampleBuffer: CMSampleBuffer,
        with sampleBufferType:
        RPSampleBufferType
    ) {
        
        guard sampleBufferType == .video else {
            return
        }
        NSLog("Processing Video Buffer")
        
        guard CMSampleBufferDataIsReady(
            sampleBuffer
        ) else {
            return
        }
        
        if assetWriter?.status == .unknown {
            
            assetWriter?.startWriting()
            
            assetWriter?.startSession(
                atSourceTime:
                    CMSampleBufferGetPresentationTimeStamp(
                        sampleBuffer
                    )
            )
        }
        
        if assetWriter?.status == .writing {
            
            if videoInput?.isReadyForMoreMediaData
                == true {
                
                videoInput?.append(sampleBuffer)
                NSLog("FRAME APPENDED")
            }
        }
    }
    
    // MARK: Broadcast Finished
    
//    override func broadcastFinished() {
//
//        videoInput?.markAsFinished()
//
//        assetWriter?.finishWriting {
//
//            guard let outputURL = self.outputURL else {
//                return
//            }
//
//            NSLog("GLOBAL SCREEN RECORDING SAVED:")
//            NSLog(outputURL.absoluteString)
//
//            guard let containerURL =
//                    FileManager.default.containerURL(
//                        forSecurityApplicationGroupIdentifier:
//                            "group.com.streamgate.broadcast"
//                    ) else {
//
//                NSLog("NO APP GROUP CONTAINER")
//                return
//            }
//
//            let metadataURL =
//                containerURL
//                .appendingPathComponent(
//                    "latestRecording.txt"
//                )
//
//            do {
//
//                try outputURL.absoluteString.write(
//                    to: metadataURL,
//                    atomically: true,
//                    encoding: .utf8
//                )
//
//                NSLog("VIDEO PATH SAVED SUCCESSFULLY")
//
//            } catch {
//
//                NSLog("FAILED TO SAVE VIDEO PATH")
//                NSLog(error.localizedDescription)
//            }
//        }
//    }
//

    override func broadcastFinished() {

        NSLog("Broadcast Finished Called")

        videoInput?.markAsFinished()

        assetWriter?.finishWriting { [weak self] in

            guard let self = self else {
                return
            }

            NSLog("finishWriting completed")

            guard let outputURL = self.outputURL else {

                NSLog("OUTPUT URL NIL")
                return
            }

            NSLog("VIDEO SAVED:")
            NSLog(outputURL.absoluteString)

            let defaults = UserDefaults(
                suiteName: "group.com.streamgate.broadcast"
            )

            defaults?.set(
                outputURL.absoluteString,
                forKey: "recordedVideoURL"
            )

            defaults?.synchronize()

            NSLog("URL SAVED SUCCESSFULLY")
        }
    }
}
