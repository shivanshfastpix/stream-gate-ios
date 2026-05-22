import SwiftUI
import Combine
import ReplayKit

struct RecordView: View {
    @State private var showCamera = false
    @State private var navigateToPreview = false
    @State private var recordedVideoURL: URL?
    @State private var isRecording = false          // ← tracks broadcast state

    let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    @StateObject private var vm = UploadViewModel()

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ZStack {
                    Color.black.ignoresSafeArea()

                    VStack(spacing: 60) {
                        HeaderRecordSection()

                        VStack(spacing: 18) {
                            RecordCameraSection { showCamera = true }

                            RecordScreenSection(
                                onTap: {
                                    if isRecording {
                                        print("clicked button for recording so clean old video")
                                        // User wants to stop — clean up,
                                        // the extension handles finalization
                                        clearPreviousRecording()
                                    }
                                    // If starting: clearPreviousRecording called on appear
                                },
                                isRecording: $isRecording
                            )
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
                    syncRecordingState()    // ← poll RPScreenRecorder
                    checkForBroadcastVideo()
                }
                .onAppear {
                    clearPreviousRecording()
                    print("[StreamGate_MAIN] View appeared. Timer started.")
                }
            }
        } else {
            Text("iOS 16 Required")
        }
    }

    // ── Sync UI with actual broadcast state ──────────────────────────────────
    private func syncRecordingState() {
        let broadcasting = UserDefaults(suiteName: "group.com.streamgate.broadcast")?
            .bool(forKey: "isBroadcasting") ?? false

        if isRecording != broadcasting {
            isRecording = broadcasting
            print("[StreamGate_MAIN] 📡 Recording state changed → \(broadcasting ? "STARTED" : "STOPPED")")
        }
    }

    // ── Detect completed file ─────────────────────────────────────────────────
    private func checkForBroadcastVideo() {
        guard let defaults = UserDefaults(suiteName: "group.com.streamgate.broadcast"),
              let path = defaults.string(forKey: "recordedVideoURL"),
              FileManager.default.fileExists(atPath: path) else { return }

        defaults.removeObject(forKey: "recordedVideoURL")
        self.recordedVideoURL = URL(fileURLWithPath: path)
        print("[StreamGate_MAIN] ✅ recorded video url: \(path)")
        self.navigateToPreview = true
    }

    // ── Cleanup ───────────────────────────────────────────────────────────────
    private func clearPreviousRecording() {
        let suite = "group.com.streamgate.broadcast"
        guard let defaults = UserDefaults(suiteName: suite) else { return }

        if let path = defaults.string(forKey: "recordedVideoURL") {
            let fileURL = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try? FileManager.default.removeItem(at: fileURL)
                print("[StreamGate_MAIN] 🗑 Deleted previous recording: \(fileURL.lastPathComponent)")
            }
        }

        defaults.removeObject(forKey: "recordedVideoURL")
        defaults.synchronize()
        print("[StreamGate_MAIN] 🧹 Cleared recordedVideoURL from UserDefaults")
    }
}
