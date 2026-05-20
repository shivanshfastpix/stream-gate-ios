import SwiftUI

func getLatestRecording() -> URL? {

    let defaults = UserDefaults(
        suiteName: "group.com.streamgate.broadcast"
    )

    guard let path =
            defaults?.string(
                forKey: "recordedVideoURL"
            ) else {

        print("NO RECORDING FOUND")
        return nil
    }

    print("FOUND PATH:")
    print(path)

    return URL(string: path)
}

struct RecordView: View {
    
    func startPollingForRecording() {

        pollingTimer?.invalidate()

        pollingTimer = Timer.scheduledTimer(
            withTimeInterval: 2,
            repeats: true
        ) { _ in

            if let fileURL = getLatestRecording() {

                print("FOUND VIDEO:")
                print(fileURL)

                recordedVideoURL = fileURL

                navigateToPreview = true

                pollingTimer?.invalidate()

                // Clear Saved Path

                let defaults = UserDefaults(
                    suiteName: "group.com.streamgate.broadcast"
                )

                defaults?.removeObject(
                    forKey: "recordedVideoURL"
                )
            }
        }
    }
    
//    func getLatestRecording() -> URL? {
//
//        guard let containerURL =
//                FileManager.default.containerURL(
//                    forSecurityApplicationGroupIdentifier:
//                        "group.com.streamgate.broadcast"
//                ) else {
//
//            print("NO CONTAINER")
//            return nil
//        }
//
//        let metadataURL =
//            containerURL
//            .appendingPathComponent(
//                "latestRecording.txt"
//            )
//
//        do {
//
//            let path = try String(
//                contentsOf: metadataURL
//            )
//
//            print("FOUND VIDEO PATH:")
//            print(path)
//
//            return URL(string: path)
//
//        } catch {
//
//            print("FAILED TO READ VIDEO PATH")
//            print(error.localizedDescription)
//
//            return nil
//        }
//    }
    
    @State private var showCamera = false
    @State private var navigateToPreview = false
    @State private var recordedVideoURL: URL?
    @State private var pollingTimer: Timer?
    
    var body: some View {
        
        
        if #available(iOS 16.0, *) {
            
            NavigationStack {
                
                ZStack {
                    
                    Color.black
                        .ignoresSafeArea()
                    
                    VStack(spacing:60) {

                        HeaderRecordSection()
                        
                        VStack(spacing:18){
                            RecordCameraSection {
                                showCamera = true
                            }
                            
                            RecordScreenSection()
                            
                        }
                      
                        
                       
                    }
                }
                .sheet(isPresented: $showCamera) {
                    
                    VideoRecorderView { videoURL in
                        
                        recordedVideoURL = videoURL
                        
                        navigateToPreview = true
                    }
                }
                .navigationDestination(
                    isPresented: $navigateToPreview
                ) {
                    
                    if let videoURL = recordedVideoURL {
                        
                        UploadPreviewView(
                            videoURL: videoURL
                        )
                    }
                }.onAppear {
                    
                    print("RecordView appeared")

                    startPollingForRecording()
                }
            }
            
        } else {
            
            Text("iOS 16 Required")
        }
    }
}

#Preview {
    RecordView()
}
