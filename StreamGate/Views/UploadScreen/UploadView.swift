import SwiftUI
import PhotosUI
import AVKit

@available(iOS 16.0, *)
struct UploadView: View {

    @StateObject private var vm = UploadViewModel()

    @State private var selectedItem: PhotosPickerItem?
    @State private var player = AVPlayer()
    @State private var selectedVideoURL: URL?

    var body: some View {

        if #available(iOS 17.0, *) {
            NavigationStack {
                
                ZStack {
                    
                    Color.black
                        .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        
                        VStack(spacing: 24) {
                            
                            HeaderSection()
                            
                            // Video Picker
                            
                        if(selectedVideoURL == nil)
                            {
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .videos
                            ) {
                                
                                UploadDropZone()
                            }
                        }
                            
                            if selectedVideoURL != nil {
                                
                                VideoPlayer(player: player)
                                    .frame(height: 300)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 24)
                                    )
                            }
                            
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
                                
                                Text("Upload Completed")
                                    .foregroundStyle(.green)
                                    .fontWeight(.semibold)
                            }
                            
                            if let error = vm.uploadError {

                                VStack(spacing: 12) {

                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.red)
                                        .font(.title2)

                                    Text(error)
                                        .foregroundStyle(.red)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                            }
                            
                            SeparatorSection()
                            
                            NavigationLink {
                                
                                RecordView()
                                
                            } label: {
                                
                                RecordButton()
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 40)
                        .frame(maxWidth: 500)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .onChange(of: selectedItem) {
                
                Task {
                    
                    guard let item = selectedItem else {
                        return
                    }
                    
                    do {
                        
                        if let movie = try await item.loadTransferable(
                            type: CustomMovieFile.self
                        ) {
                            
                            // Store Selected Video URL
                            
                            selectedVideoURL = movie.url
//                            print("video url is  : \(movie.url)")
                            
                            // Create Player Item
                            
                            let playerItem = AVPlayerItem(
                                url: movie.url
                            )
                            
                            // Load Into Video Player
                            
                            player.replaceCurrentItem(
                                with: playerItem
                            )
                            
                            // Auto Play
                            
                            player.play()
                            
                            // Start Upload
                            
                            await vm.uploadVideo(
                                fileURL: movie.url
                            )
                        }
                        
                    } catch {
                        
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
