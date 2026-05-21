import SwiftUI
import Combine

struct RecordView: View {
    @State private var showCamera = false
    @State private var navigateToPreview = false
    @State private var recordedVideoURL: URL?
    
    let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    
                    VStack(spacing: 60) {
                        HeaderRecordSection()
                        
                        VStack(spacing: 18) {
                            RecordCameraSection { showCamera = true }
                            RecordScreenSection()
                        }
                    }
                }
                .sheet(isPresented: $showCamera) {
                    VideoRecorderView { videoURL in
                        self.recordedVideoURL = videoURL
                        self.navigateToPreview = true
                    }
                }
                .navigationDestination(isPresented: $navigateToPreview) {
                    if let videoURL = recordedVideoURL {
                        UploadPreviewView(videoURL: videoURL)
                    }
                  
                }
                .onReceive(timer) { _ in
                    checkForBroadcastVideo()
                }
                .onAppear {
                    print("[StreamGate_MAIN] View appeared. Timer started.")
                }
            }
        } else {
            Text("iOS 16 Required")
        }
    }
    
    private func checkForBroadcastVideo() {
        print("[StreamGate_MAIN] ⏱️ Scanning App Group Directory directly...")
        
        // 1. Get direct disk path to your App Group folder
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.streamgate.broadcast") else {
            print("[StreamGate_MAIN] ❌ CRITICAL: Main App cannot find App Group Container. Entitlements are missing or broken!")
            return
        }
        
        do {
            // 2. Read the directory contents looking for .mp4 files
            let contents = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            let mp4Files = contents.filter { $0.pathExtension.lowercased() == "mp4" }
            
            print("[StreamGate_MAIN] Found \(mp4Files.count) total mp4 recordings in container folder.")
            
            // 3. Find the newest one
            let sortedFiles = mp4Files.sorted { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                return date1 > date2
            }
            
            if let latestVideoURL = sortedFiles.first {
                // 4. Double check that the asset writer finished saving it (file size > 0)
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: latestVideoURL.path)
                if let fileSize = fileAttributes[.size] as? UInt64, fileSize > 0 {
                    
                    print("[StreamGate_MAIN] ✅ SUCCESS! Found finalized video: \(latestVideoURL.path)")
                    
                    // Halt the system loop and route views
                    self.recordedVideoURL = latestVideoURL
                    self.navigateToPreview = true
                } else {
                    print("[StreamGate_MAIN] ⏳ Found video file, but its size is 0 bytes. Extension is still writing frames...")
                }
            }
        } catch {
            print("[StreamGate_MAIN] ❌ Failed to scan directory path: \(error.localizedDescription)")
        }
    }
}
