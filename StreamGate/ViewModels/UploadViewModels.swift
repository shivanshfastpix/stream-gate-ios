import fp_swift_upload_sdk

final class UploadViewModel: ObservableObject {

    private let uploader = Uploads()

    func uploadVideo(
        fileURL: URL
    ) async {

        do {

            let response = try await StreamGateServices()
                .sendUploadRequest()

            uploader.uploadFile(
                file: fileURL,
                endpoint: response.url,
                chunkSizeKB: 5120
            )

        } catch {

            print(error.localizedDescription)
        }
    }
    
    func pauseUpload()async throws{
         try await uploader.pause()
        
    }
    
    func resumeUpload()async throws{
         try await uploader.resume()
        
    }
}
