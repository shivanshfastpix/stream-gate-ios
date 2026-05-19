import SwiftUI
import AVKit

struct UploadPreviewView: View {
    
    let videoURL: URL
    
    @StateObject private var vm = UploadViewModel()
    
    @State private var player = AVPlayer()
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                
                VStack(spacing: 24) {
                    ZStack {
                               Color.black.ignoresSafeArea()

                               VStack {
//                                   Text("Upload Screen")
                               }
                           }
                           .navigationTitle("Upload Video")
                           .navigationBarTitleDisplayMode(.inline)
                    
                    // Video Player
                    
                    VideoPlayer(player: player)
                        .frame(height: 300)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 24)
                        )
                    
                    // Upload Progress
                    
                    if vm.isUploading {
                        
                        VStack(spacing: 12) {
                            
                            ProgressView(
                                value: vm.uploadProgress
                            )
                            .tint(.orange)
                            
                            Text(
                                "\(Int(vm.uploadProgress * 100))%"
                            )
                            .foregroundStyle(.white)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Upload Success
                    
                    if vm.uploadCompleted {
                        
                        if #available(iOS 16.0, *) {
                            Text("Upload Completed")
                                .foregroundStyle(.green)
                                .fontWeight(.semibold)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    
                    // Shared URL
                    
                    if let sharedURL = vm.sharedURL {
                        
                        VStack(spacing: 16) {
                            
                            if #available(iOS 16.0, *) {
                                Text("Video Ready")
                                    .foregroundStyle(.green)
                                    .fontWeight(.bold)
                            } else {
                                // Fallback on earlier versions
                            }
                            
                            Text(sharedURL)
                                .foregroundStyle(.white)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                
                                Button("Copy Link") {
                                    UIPasteboard.general.string =
                                    sharedURL
                                }
                                
                                Button("Preview") {
                                    
                                    if let url = URL(string: sharedURL) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Error
                    
                    if let error = vm.uploadError {
                        
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
        }
        .task {
            
            // Setup Player
            
            let playerItem = AVPlayerItem(
                url: videoURL
            )
            
            player.replaceCurrentItem(
                with: playerItem
            )
            
            player.play()
            
            // Upload
            
            await vm.uploadVideo(
                fileURL: videoURL
            )
        }
    }
}
