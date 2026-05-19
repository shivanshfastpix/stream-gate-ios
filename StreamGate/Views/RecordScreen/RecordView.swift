import SwiftUI

struct RecordView: View {
    
    @State private var showCamera = false
    @State private var navigateToPreview = false
    @State private var recordedVideoURL: URL?
    
    var body: some View {
        
        if #available(iOS 16.0, *) {
            
            NavigationStack {
                
                ZStack {
                    
                    Color.black
                        .ignoresSafeArea()
                    
                    VStack {
                        
                        HeaderRecordSection()
                        
                        RecordCameraSection {
                            showCamera = true
                        }
                        
                        RecordScreenSection()
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
