import SwiftUI
import PhotosUI

struct UploadView: View {

//    @StateObject private var vm = UploadViewModel()

//    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        
        NavigationStack{
            ZStack {

                Color.black
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {

                    VStack(spacing: 24) {

                        HeaderSection()

    //                    uploadSection
                        
                        UploadDropZone()
                        {
                            print("uploading the video.....")
                            Task {

                                    do {

                                        try await StreamGateServices()
                                            .sendUploadRequest()

                                    } catch {

                                        print(error)
                                    }
                                }
                        }

                        SeparatorSection()

                        NavigationLink {
                            RecordView()
                        } label:{

                            RecordButton()

                        }
                       

    //                    stateSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 40)
                    .frame(maxWidth: 500)
                    .frame(maxWidth: .infinity)
                }
            }
    //        .onChange(of: selectedItem) {
    //
    //            Task {
    //
    //                guard let item = selectedItem else {
    //                    return
    //                }
    //
    //                do {
    //
    ////                    let url = try await loadVideoURL(
    ////                        from: item
    ////                    )
    ////
    ////                    await vm.uploadVideo(
    ////                        fileURL: url
    ////                    )
    ////                } catch {
    ////
    ////                    print(error)
    //                }
    //            }
            }
            
        }
       
    }
//}

//private extension UploadView {
//
//    var uploadSection: some View {
//
//        PhotosPicker(
//            selection: $selectedItem,
//            matching: .videos
//        ) {
//
//            UploadDropZone {
//
//            }
//        }
//    }
//
//    @ViewBuilder
//    var stateSection: some View {
//
//        switch vm.uploadState {
//
//        case .idle:
//
//            EmptyView()
//
//        case .uploading(let progress):
//
//            UploadProgressView(
//                progress: progress
//            )
//
//        case .processing:
//
//            VStack(spacing: 16) {
//
//                ProgressView()
//
//                Text("Processing video...")
//                    .foregroundStyle(.white)
//            }
//
//        case .completed(let playbackURL):
//
//            VideoPreviewCard(
//                playbackURL: playbackURL
//            )
//
//        case .failed(let message):
//
//            Text(message)
//                .foregroundStyle(.red)
//
//        case .selecting:
//
//            Text("Selecting video...")
//                .foregroundStyle(.white)
//        }
//    }
//}
//
//private extension UploadView {
//
//    func loadVideoURL(
//        from item: PhotosPickerItem
//    ) async throws -> URL {
//
//        let temporaryDirectory =
//            FileManager.default.temporaryDirectory
//
//        let temporaryURL =
//            temporaryDirectory
//            .appendingPathComponent(
//                UUID().uuidString + ".mov"
//            )
//
//        guard let videoData =
//                try await item.loadTransferable(
//                    type: Data.self
//                ) else {
//
//            throw URLError(.badURL)
//        }
//
//        try videoData.write(to: temporaryURL)
//
//        return temporaryURL
//    }
//}

#Preview {
    UploadView()
}
