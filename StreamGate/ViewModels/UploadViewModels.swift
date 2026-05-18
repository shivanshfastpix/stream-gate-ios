import Foundation
import fp_swift_upload_sdk
import Combine

@MainActor
final class UploadViewModel: NSObject,ObservableObject, UploadSDKErrorDelegate  {
    func uploadSDKDidFail(
            with error: String
        ) {

            DispatchQueue.main.async {

                self.isUploading = false

                self.uploadCompleted = false

                self.uploadError = self.mapSDKError(error)
            }
        }
    

    @Published var uploadProgress: Double = 0
    @Published var isUploading = false
    @Published var uploadCompleted = false
    @Published var uploadError: String?
    
    
   
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let uploader = Uploads()
//    private let service = StreamGateServices()
    private let uploadService = UploadService()
    
    override init() {

         super.init()

         uploader.errorDelegate = self
     }
    

    func uploadVideo(
        fileURL: URL
    ) async {
        print("uploading the video")
//        resetState()

        do {

            isUploading = true
            uploadCompleted = false

            // getting the url
//            let response = try await service.sendUploadRequest()
            let signedUrl = try await uploadService.createDirectUpload()
            print("response / signed url : \(signedUrl)")

            // sdk handler to see the progress
//            uploader.progressHandler = { [weak self] progress in
//                print("inside the handler...progress => \(progress)")
//                DispatchQueue.main.async {
//
//                    self?.uploadProgress = Double(progress)
//
//                    if progress >= 1.0 {
//
//                        self?.isUploading = false
//                        self?.uploadCompleted = true
//                    }
//                }
//            }
            
            uploader.progressHandler = { [weak self] progress in
                
                guard let self else { return }
                
                print("progress => \(progress)")
                
                Task { @MainActor in
                    
                    self.uploadProgress = Double(progress)
                    
                    if progress >= 0.999 {
                        
                        self.isUploading = false
                        self.uploadCompleted = true
                    }
                }
            }
            
           print("uploading the file in sdk : \(fileURL)")
            // uploading file url to sdk
           uploader.uploadFile(
                file: fileURL,
                endpoint: signedUrl.absoluteString,
                chunkSizeKB: 10
            )

        } catch {
            print("============ getting error =======")
            print(error.localizedDescription)
            handleSystemError(error)
        }
    }
    
    private func handleSystemError(
            _ error: Error
        ) {

            isUploading = false

            uploadCompleted = false

            if let urlError = error as? URLError {

                switch urlError.code {

                case .notConnectedToInternet:

                    uploadError = "No internet connection."

                case .timedOut:

                    uploadError = "The request timed out."

                case .cannotFindHost:

                    uploadError = "Server not reachable."

                default:

                    uploadError = urlError.localizedDescription
                }

            } else {

                uploadError = error.localizedDescription
            }
        }

        // MARK: - SDK Error Mapping

        private func mapSDKError(
            _ error: String
        ) -> String {

            let lowercased = error.lowercased()

            if lowercased.contains("network") {

                return "Network issue during upload."

            } else if lowercased.contains("timeout") {

                return "Upload timed out."

            } else if lowercased.contains("permission") {

                return "Permission denied."

            } else if lowercased.contains("abort") {

                return "Upload was cancelled."

            }

            return error
        }

    
    func resetState() {

        uploadProgress = 0

        isUploading = false

        uploadCompleted = false

        uploadError = nil
    }


    func pauseUpload() {

        uploader.pause()
    }


    func resumeUpload() {

        uploader.resume()
    }


    func abortUpload() {

        uploader.abort()

        resetState()
    }
}
