import Foundation

private let apiKey: String = "https://api.fastpix.io/v1/on-demand/upload"

private let accessTokenID: String = "e33d37ea-cc8c-4907-8d71-ea902545e3ad"
private let secretKey: String = "723e262a-a11e-4ece-9270-ddb975f97f23"

import Foundation

final class UploadService {
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func createDirectUpload() async throws -> (URL, String)? {
        
        let parameters: [String: Any] = [
                    "corsOrigin": "*",
        
                    "pushMediaSettings": [
                        "accessPolicy": "public",
                        "generateSubtitles": true,
                        "normalizeAudio": true,
                        "maxResolution": "1080p",
        //                "mediaQuality": "standard"
                    ]
                ]
                
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            throw NSError(domain: "com.example.app", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to serialize parameters"
            ])
        }
        
        let request = try {
            var req = try URLRequest(url: fullURL(forEndpoint: "upload"))
            req.httpBody = jsonData
            req.httpMethod = "POST"
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            req.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let credentials = "\(accessTokenID):\(secretKey)"
            let basicAuthCredential = Data(credentials.utf8).base64EncodedString()
            req.addValue("Basic \(basicAuthCredential)", forHTTPHeaderField: "Authorization")
            
            return req
        }()
        
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CreateUploadError.custom("Invalid HTTP response")
        
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            do {
                if let jsonDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataDic = jsonDictionary["data"] as? [String: Any],
                   let uploadId = dataDic["uploadId"] as? String,
                   let urlString = dataDic["url"] as? String,
                   
                   let uploadUrl = URL(string: urlString) {
                    print("data from fastpix server : \(dataDic)")
                    print("upload id : \(uploadId)")
                    return (uploadUrl, uploadId)
                } else {
                    print("Failed to parse upload URL from response.")
                    return nil
                }
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                return nil
            }
        } else {
            print("---- getting error ---")
            let errorMessage = String(decoding: data, as: UTF8.self)
            throw CreateUploadError.custom("Upload POST failed: HTTP \(httpResponse.statusCode):\n\(errorMessage)")
        }
    }
    
//    func getPlayBackId(videoId: String) async throws -> String {
//
//        let credentials = "\(accessTokenID):\(secretKey)"
//
//        guard let url = URL(
//            string: "https://api.fastpix.io/v1/on-demand/uploads\(videoId)"
//        ) else {
//            throw URLError(.badURL)
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        request.setValue(
//            "Basic \(credentials)",
//            forHTTPHeaderField: "Authorization"
//        )
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse,
//              (200...299).contains(httpResponse.statusCode) else {
//            throw URLError(.badServerResponse)
//        }
//        print("get request to get the signed url : \(data)")
//
//        let decoded = try JSONDecoder().decode(
//            MediaResponse.self,
//            from: data
//        )
//        print("decoded data for playback id : \(decoded)")
//        print(decoded.data.playbackIds.first?.id ?? "")
//        return decoded.data.playbackIds.first?.id ?? ""
//    }
    
    func getResponse(
        uploadId: String
    ) async -> (String, String?)? {

        print("entering getMediaStatus for upload id : \(uploadId)")

        let credentials = Data(
            "\(accessTokenID):\(secretKey)".utf8
        ).base64EncodedString()

        guard let url = URL(
            string: "https://api.fastpix.io/v1/on-demand/\(uploadId)"
        ) else {

            return nil
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        request.setValue(
            "Basic \(credentials)",
            forHTTPHeaderField: "Authorization"
        )

        do {

            let (data, response) =
            try await URLSession.shared.data(for: request)

            guard let httpResponse =
                    response as? HTTPURLResponse else {

                return nil
            }

            print("status code => \(httpResponse.statusCode)")

            // ignore temporary server errors
            guard (200...299).contains(
                httpResponse.statusCode
            ) else {

                print("video not ready yet")
                return nil
            }

            let decoded = try JSONDecoder().decode(
                MediaResponse.self,
                from: data
            )

            let status = decoded.data.status

            let playbackId =
            decoded.data.playbackIds.first?.id

            print("status => \(status)")
            print("playbackId => \(playbackId ?? "")")

            return (status, playbackId)

        } catch {

            print("temporary polling error: \(error)")
            return nil
        }
    }
    
    func getMediaStatus(
        mediaId: String
    ) async throws -> (String, String?) {

        print("entering getMediaStatus")

        let credentials = Data(
            "\(accessTokenID):\(secretKey)".utf8
        ).base64EncodedString()

        guard let url = URL(
            string: "https://api.fastpix.io/v1/on-demand/upload/\(mediaId)"
        ) else {

            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        request.setValue(
            "Basic \(credentials)",
            forHTTPHeaderField: "Authorization"
        )

        let (data, response) =
        try await URLSession.shared.data(for: request)

        guard let httpResponse =
                response as? HTTPURLResponse else {

            throw URLError(.badServerResponse)
        }

        print("status code => \(httpResponse.statusCode)")

        if let jsonString =
            String(data: data, encoding: .utf8) {

            print("response => \(jsonString)")
        }

        guard (200...299).contains(
            httpResponse.statusCode
        ) else {

            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(
            MediaResponse.self,
            from: data
        )

        let status = decoded.data.status

        let playbackId =
        decoded.data.playbackIds.first?.id

        print("status => \(status)")
        print("playbackId => \(playbackId ?? "")")

        return (status, playbackId)
    }

    /// Generates a full URL for a given endpoint in the FastPix Video public API
    private func fullURL(forEndpoint endpoint: String) throws -> URL {
        let fullPath = "https://api.fastpix.io/v1/on-demand/\(endpoint)"
        guard let url = URL(string: fullPath) else {
           print("error on full url : bad endpoint \(endpoint)")
            throw CreateUploadError.custom("Bad endpoint: \(endpoint)")
        }
        return url
    }
    


//    func createDirectUpload() async throws -> URL {
//        
//        let parameters: [String: Any] = [
//            "corsOrigin": "*",
//            
//            "pushMediaSettings": [
//                "accessPolicy": "public",
//                "generateSubtitles": true,
//                "normalizeAudio": true,
//                "maxResolution": "1080p",
////                "mediaQuality": "standard"
//            ]
//        ]
//        
//        let jsonData = try JSONSerialization.data(
//            withJSONObject: parameters
//        )
//        
//        // DEBUG
//        if let jsonString = String(data: jsonData, encoding: .utf8) {
//            print("REQUEST JSON:")
//            print(jsonString)
//        }
//        
//        guard let url = URL(
//            string: "https://api.fastpix.com/v1/on-demand/upload"
//        ) else {
//            throw URLError(.badURL)
//        }
//        
//        var request = URLRequest(url: url)
//        
//        request.httpMethod = "POST"
//        request.httpBody = jsonData
//        
//        request.setValue(
//            "application/json",
//            forHTTPHeaderField: "Content-Type"
//        )
//        
//        request.setValue(
//            "application/json",
//            forHTTPHeaderField: "Accept"
//        )
//        
//        let credentials = "\(accessTokenID):\(secretKey)"
//        
//        let encodedCredentials = Data(credentials.utf8)
//            .base64EncodedString()
//        
//        request.setValue(
//            "Basic \(encodedCredentials)",
//            forHTTPHeaderField: "Authorization"
//        )
//        
//        let (data, response) = try await urlSession.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw UploadServiceError.invalidResponse
//        }
//        
//        print("STATUS CODE:", httpResponse.statusCode)
//        
//        if let responseString = String(data: data, encoding: .utf8) {
//            print("RESPONSE:")
//            print(responseString)
//        }
//        
//        guard (200...299).contains(httpResponse.statusCode) else {
//            
//            let serverMessage = String(
//                data: data,
//                encoding: .utf8
//            ) ?? "Unknown error"
//            
//            throw UploadServiceError.serverError(
//                statusCode: httpResponse.statusCode,
//                message: serverMessage
//            )
//        }
//        
//        let decoded = try JSONDecoder()
//            .decode(CreateDirectUploadResponse.self, from: data)
//        
//        guard let uploadURL = URL(string: decoded.data.url) else {
//            throw UploadServiceError.invalidResponse
//        }
//        print(uploadURL)
//        return uploadURL
////        return decoded.data.url
//    }
}

enum CreateUploadError: LocalizedError {
    
    case invalidResponse
    case invalidUploadURL
    case serializationFailed
    case badEndpoint(String)
    case serverError(statusCode: Int, message: String)
    case custom(String)
    
    var errorDescription: String? {
        switch self {
            
        case .invalidResponse:
            return "Invalid HTTP response received from server."
            
        case .invalidUploadURL:
            return "Failed to generate a valid upload URL."
            
        case .serializationFailed:
            return "Failed to serialize request body."
            
        case .badEndpoint(let endpoint):
            return "Invalid endpoint: \(endpoint)"
            
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
            
        case .custom(let message):
            return message
        }
    }
}
