import Foundation

private let apiKey: String = "https://api.fastpix.io/v1/on-demand/upload"

private let accessTokenID: String = "3a8df6d0-6d9c-49f7-a7d5-ea22dc35c898"
private let secretKey: String = "704f9206-d427-4f09-86ab-e98be8be87eb"

import Foundation

final class UploadService {
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func createDirectUpload() async throws -> URL {
        
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
        
        let jsonData = try JSONSerialization.data(
            withJSONObject: parameters
        )
        
        // DEBUG
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("REQUEST JSON:")
            print(jsonString)
        }
        
        guard let url = URL(
            string: "https://api.fastpix.com/v1/on-demand/upload"
        ) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )
        
        let credentials = "\(accessTokenID):\(secretKey)"
        
        let encodedCredentials = Data(credentials.utf8)
            .base64EncodedString()
        
        request.setValue(
            "Basic \(encodedCredentials)",
            forHTTPHeaderField: "Authorization"
        )
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UploadServiceError.invalidResponse
        }
        
        print("STATUS CODE:", httpResponse.statusCode)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("RESPONSE:")
            print(responseString)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            
            let serverMessage = String(
                data: data,
                encoding: .utf8
            ) ?? "Unknown error"
            
            throw UploadServiceError.serverError(
                statusCode: httpResponse.statusCode,
                message: serverMessage
            )
        }
        
        let decoded = try JSONDecoder()
            .decode(CreateDirectUploadResponse.self, from: data)
        
        guard let uploadURL = URL(string: decoded.data.url) else {
            throw UploadServiceError.invalidResponse
        }
        print(uploadURL)
        return uploadURL
//        return decoded.data.url
    }
}
