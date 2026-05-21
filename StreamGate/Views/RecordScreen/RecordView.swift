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
                        //                        Button("Check Extension Sentinel") {
                        //                            let suiteName = "group.com.streamgate.broadcast"
                        //                            let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)
                        //                            let sentinel = container?.appendingPathComponent("EXTENSION_RAN.txt")
                        //                            let fileExists = sentinel.map { FileManager.default.fileExists(atPath: $0.path) } ?? false
                        //                            let lastRan = UserDefaults(suiteName: suiteName)?.object(forKey: "extensionLastRan") as? Date
                        //                            let contents = sentinel.flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? "nil"
                        //
                        //                            print("""
                        //                            ───────── EXTENSION SENTINEL CHECK ─────────
                        //                            container URL : \(container?.path ?? "❌ nil — App Group not configured on MAIN app")
                        //                            sentinel path : \(sentinel?.path ?? "n/a")
                        //                            file exists   : \(fileExists ? "✅ YES" : "❌ NO")
                        //                            file contents : \(contents)
                        //                            last ran (UD) : \(lastRan.map { "\($0)" } ?? "nil")
                        //                            ────────────────────────────────────────────
                        //                            """)
                        //                        }
                        //                        .foregroundColor(.white)
                        //                        .padding()
                        //                        .background(Color.blue)
                        
                        HeaderRecordSection()
                        
                        VStack(spacing: 18) {
                            RecordCameraSection { showCamera = true }
                            RecordScreenSection()
                            {
                                // remove the video
                                clearPreviousRecording()
                            }
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
                    
                    //                    if(saved != nil)
                    //                    {
                    //                        Task{
                    //                            print("uploading the sdk")
                    //                            await vm.uploadVideo(
                    //                                fileURL:fileurl!
                    //                            )
                    //                        }
                    //
                    //                    }
                    
                    
                    
                }
                
                .foregroundColor(.white).padding().background(Color.purple)
                
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
//                    clearPreviousRecording()
                }
            }
        } else {
            Text("iOS 16 Required")
        }
    }
    
    private func checkForBroadcastVideo() {
        print("checking the broadcast")
        guard let defaults = UserDefaults(suiteName: "group.com.streamgate.broadcast"),
              let path = defaults.string(forKey: "recordedVideoURL"),
              FileManager.default.fileExists(atPath: path) else { return }
        
        defaults.removeObject(forKey: "recordedVideoURL")   // consume it
        self.recordedVideoURL = URL(fileURLWithPath: path)
        print("recorded video url : \(self.recordedVideoURL ?? URL(string : "no url "))")
        self.navigateToPreview = true
    }
    
    private func clearPreviousRecording() {
        let suite = "group.com.streamgate.broadcast"

        guard let defaults = UserDefaults(suiteName: suite) else { return }

        // 1. Delete the mp4 file if it still exists on disk
        if let path = defaults.string(forKey: "recordedVideoURL") {
            let fileURL = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    print("[StreamGate_MAIN] 🗑 Deleted previous recording: \(fileURL.lastPathComponent)")
                } catch {
                    print("[StreamGate_MAIN] ⚠️ Could not delete previous recording: \(error.localizedDescription)")
                }
            }
        }

        // 2. Clear the UserDefaults signal so the timer doesn't pick up a stale path
        defaults.removeObject(forKey: "recordedVideoURL")
        defaults.synchronize()
        print("[StreamGate_MAIN] 🧹 Cleared recordedVideoURL from UserDefaults")
    }
    
    
    
}
