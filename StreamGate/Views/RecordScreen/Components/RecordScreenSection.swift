import SwiftUI

struct RecordScreenSection: View {
    
    @StateObject private var recorder =
    ScreenRecorder.shared
    
    @StateObject private var vm = UploadViewModel()
    
    @State private var isLoading = false
    
    var body: some View {
        
        Button {
            
            Task {
                
                do {
                    
                    if recorder.isRecording {
                        
                        isLoading = true
                        
                        let fileURL =
                        try await recorder.stopRecording()
                        
                        isLoading = false
                        
                        print(fileURL)
                        
                        // Upload To FastPix
                        
                        // await vm.uploadVideo(fileURL: fileURL)
                        Task {
                            await vm.uploadVideo(
                                fileURL: fileURL
                            )
                        }
                        
                    } else {
                        
                        try await recorder.startRecording()
                    }
                    
                } catch {
                    
                    print(error.localizedDescription)
                }
            }
            
        } label: {
            
            HStack(spacing: 14) {
                
                Image(systemName:
                        recorder.isRecording
                      ? "stop.circle.fill"
                      : "record.circle.fill"
                )
                .font(
                    .system(size: 28, weight: .semibold)
                )
                
                Text(
                    recorder.isRecording
                    ? "Stop Recording"
                    : "Record Screen"
                )
                .font(
                    .system(size: 22, weight: .bold)
                )
            }
            .foregroundColor(.white)
            .frame(maxWidth: 300)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.black.opacity(0.12))
            )
        }
    }
}
