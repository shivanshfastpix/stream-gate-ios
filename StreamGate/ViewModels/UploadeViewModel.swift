//import Foundation
//import SwiftUI
//import fp_swift_upload_sdk
//
//@MainActor
//final class UploadViewModel:
//    ObservableObject,
//    UploadSDKErrorDelegate{
//
//    // MARK: - Published State
//
//    @Published var uploadState: UploadState = .idle
//
//    @Published var uploadProgress: Double = 0
//
//    @Published var uploadedPercentageText: String = "0%"
//
//    // MARK: - Properties
//
//    private let service = FastPixService()
//
//    private let uploader = Uploads()
//
//    // MARK: - Init
//
//    init() {
//
//        configureUploader()
//    }
//
//    // MARK: - Upload Logic
//
//    func uploadVideo(fileURL: URL) async {
//
//        do {
//
//            uploadState = .uploading(progress: 0)
//
//            let upload = try await service.createUpload()
//
//            uploader.uploadFile(
//                file: fileURL,
//                endpoint: upload.url,
//                chunkSizeKB: 512
//            )
//
//        } catch {
//
//            uploadState = .failed(
//                message: error.localizedDescription
//            )
//        }
//    }
//}
//
//extension UploadViewModel {
//
//    func uploadSDKDidFail(with error: String) {
//
//        DispatchQueue.main.async {
//
//            self.uploadState = .failed(
//                message: error
//            )
//        }
//    }
//}
//
//private extension UploadViewModel {
//
//    func configureUploader() {
//
//        // Real-time progress updates
//
//        uploader.progressHandler = { [weak self] progress in
//
//            guard let self else {
//                return
//            }
//
//            DispatchQueue.main.async {
//
//                self.uploadProgress = progress
//
//                self.uploadedPercentageText =
//                    String(format: "%.0f%%", progress * 100)
//
//                self.uploadState = .uploading(
//                    progress: progress
//                )
//                uploader.errorDelegate = self
//
//                // Upload completed
//
//                if progress >= 1.0 {
//
//                    self.uploadState = .processing
//
//                    Task {
//
//                        await self.handleUploadCompleted()
//                    }
//                }
//            }
//        }
//    }
//}
//
//private extension UploadViewModel {
//
//    func handleUploadCompleted() async {
//
//        do {
//
//            // IMPORTANT:
//            // You still need actual mediaId here.
//            // FastPix upload endpoint returns upload metadata.
//            // Store mediaId/uploadId properly.
//
//            try await Task.sleep(for: .seconds(3))
//
//            uploadState = .completed(
//                playbackURL: "https://your-playback-url.com"
//            )
//
//        } catch {
//
//            uploadState = .failed(
//                message: error.localizedDescription
//            )
//        }
//    }
//}
