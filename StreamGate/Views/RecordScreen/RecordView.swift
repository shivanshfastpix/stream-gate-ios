import SwiftUI
import Combine

struct RecordView: View {
    @State private var showCamera = false
    @State private var navigateToPreview = false
    @State private var recordedVideoURL: URL?
    
    let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    @StateObject private var vm = UploadViewModel()
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    
                    VStack(spacing: 60) {
                        Button("Check Extension Sentinel") {
                            let suiteName = "group.com.streamgate.broadcast"
                            let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)
                            let sentinel = container?.appendingPathComponent("EXTENSION_RAN.txt")
                            let fileExists = sentinel.map { FileManager.default.fileExists(atPath: $0.path) } ?? false
                            let lastRan = UserDefaults(suiteName: suiteName)?.object(forKey: "extensionLastRan") as? Date
                            let contents = sentinel.flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? "nil"
                         
                            print("""
                            ───────── EXTENSION SENTINEL CHECK ─────────
                            container URL : \(container?.path ?? "❌ nil — App Group not configured on MAIN app")
                            sentinel path : \(sentinel?.path ?? "n/a")
                            file exists   : \(fileExists ? "✅ YES" : "❌ NO")
                            file contents : \(contents)
                            last ran (UD) : \(lastRan.map { "\($0)" } ?? "nil")
                            ────────────────────────────────────────────
                            """)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        
                        HeaderRecordSection()
                        
                        VStack(spacing: 18) {
                            RecordCameraSection { showCamera = true }
                            RecordScreenSection()
                        }
                    }
                }
                
                Button("Dump Extension Diagnostics") {

                    let suite = "group.com.streamgate.broadcast"

                    guard let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suite) else {

                        print("❌ no container"); return

                    }
                 
                    print("\n========== EXTENSION DIAGNOSTICS ==========")
                 
                    // Lifecycle log

                    let logURL = dir.appendingPathComponent("LIFECYCLE.log")

                    if let text = try? String(contentsOf: logURL, encoding: .utf8) {

                        print("--- LIFECYCLE.log ---")

                        print(text)

                    } else {

                        print("--- LIFECYCLE.log MISSING ---")

                    }
                 
                    // Directory listing with sizes

                    print("--- Container contents ---")

                    if let items = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey]) {

                        for url in items {

                            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0

                            let date = (try? url.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast

                            print("  \(url.lastPathComponent)  size=\(size)  created=\(date)")

                        }

                    }
                 
                    // UserDefaults key

                    let saved = UserDefaults(suiteName: suite)?.string(forKey: "recordedVideoURL") ?? "nil"

                    print("--- UserDefaults recordedVideoURL ---")

                    print("  \(saved)")

                    print("===========================================\n")
                    let fileurl = URL(string : saved)
                    
                    if(saved != nil)
                    {
                        Task{
                            print("uploadin the sdk")
                            await vm.uploadVideo(
                                fileURL:fileurl!
                            )
                        }
                        
                    }
                    
                   

                }

                .foregroundColor(.white).padding().background(Color.purple)
                 
//                .sheet(isPresented: $showCamera) {
//                    VideoRecorderView { videoURL in
//                        self.recordedVideoURL = videoURL
//                        self.navigateToPreview = true
//                    }
//                }
//                .navigationDestination(isPresented: $navigateToPreview) {
//                    if let videoURL = recordedVideoURL {
//                        UploadPreviewView(videoURL: videoURL)
//                    }
//                }
//                .onReceive(timer) { _ in
//                    checkForBroadcastVideo()
//                }
//                .onAppear {
//                    print("[StreamGate_MAIN] View appeared. Timer started.")
//                }
            }
        } else {
            Text("iOS 16 Required")
        }
    }
    
    private func checkForBroadcastVideo() {
        guard let defaults = UserDefaults(suiteName: "group.com.streamgate.broadcast"),
              let path = defaults.string(forKey: "recordedVideoURL"),
              FileManager.default.fileExists(atPath: path) else { return }
     
        defaults.removeObject(forKey: "recordedVideoURL")   // consume it
        self.recordedVideoURL = URL(fileURLWithPath: path)
        self.navigateToPreview = true
    }
    
//    private func checkForBroadcastVideo() {
//        print("[StreamGate_MAIN] ⏱️ Scanning App Group Directory directly...")
//        
//        // 1. Get direct disk path to your App Group folder
//        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.streamgate.broadcast") else {
//            print("[StreamGate_MAIN] ❌ CRITICAL: Main App cannot find App Group Container. Entitlements are missing or broken!")
//            return
//        }
//        
//        do {
//            // 2. Read the directory contents looking for .mp4 files
//            let contents = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
//            let mp4Files = contents.filter { $0.pathExtension.lowercased() == "mp4" }
//            
//            print("[StreamGate_MAIN] Found \(mp4Files.count) total mp4 recordings in container folder.")
//            
//            // 3. Find the newest one
//            let sortedFiles = mp4Files.sorted { url1, url2 in
//                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
//                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
//                return date1 > date2
//            }
//            
//            if let latestVideoURL = sortedFiles.first {
//                // 4. Double check that the asset writer finished saving it (file size > 0)
//                let fileAttributes = try FileManager.default.attributesOfItem(atPath: latestVideoURL.path)
//                if let fileSize = fileAttributes[.size] as? UInt64, fileSize > 0 {
//                    
//                    print("[StreamGate_MAIN] ✅ SUCCESS! Found finalized video: \(latestVideoURL.path)")
//                    
//                    // Halt the system loop and route views
//                    self.recordedVideoURL = latestVideoURL
//                    self.navigateToPreview = true
//                } else {
//                    print("[StreamGate_MAIN] ⏳ Found video file, but its size is 0 bytes. Extension is still writing frames...")
//                }
//            }
//        } catch {
//            print("[StreamGate_MAIN] ❌ Failed to scan directory path: \(error.localizedDescription)")
//        }
//    }
}
