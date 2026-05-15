//import Foundation
//
//final class FastPixService {
//
//private let tokenId = "44cd01fd-b45c-43bb-ae3a-e89d01d60916"
//private let secretKey = "3ffe0f84-2d06-4811-8e96-763eaac38277"
//
//
//private var authHeader: String {
//
//    let credentials = "\(tokenId):\(secretKey)"
//
//    let base64 = Data(credentials.utf8)
//    .base64EncodedString()
//
//    return "Basic \(base64)"
//}
//
//
//func createUpload() async throws -> UploadData {
//
//    guard let url = URL(
//        string: "https://api.fastpix.io/v1/on-demand/upload"
//    ) else {
//        throw URLError(.badURL)
//    }
//
//    var request = URLRequest(url: url)
//
//    request.httpMethod = "POST"
//
//    request.setValue(
//        authHeader,
//        forHTTPHeaderField: "Authorization"
//    )
//
//    request.setValue(
//        "application/json",
//        forHTTPHeaderField: "Content-Type"
//    )
//
//    let body: [String: Any] = [
//        "cors_origin": "*"
//    ]
//
//    request.httpBody = try JSONSerialization.data(withJSONObject: body)
//
//    let (data, response) = try await URLSession.shared.data(for: request)
//
//    guard let httpResponse = response as? HTTPURLResponse,
//          
//    httpResponse.statusCode == 200 else {
//        throw URLError(.badServerResponse)
//    }
//
//    let decoded = try JSONDecoder().decode(UploadResponse.self, from: data)
//    print(decoded.data)
//    return decoded.data
//}
//
//func getMediaStatus(mediaId: String) async throws -> MediaData {
//    print("getting media status : \(mediaId)")
//    guard let url = URL(
//        string: "https://api.fastpix.io/v1/on-demand/media/\(mediaId)"
//    ) else {
//        throw URLError(.badURL)
//    }
//
//    var request = URLRequest(url: url)
//
//    request.httpMethod = "GET"
//
//    request.setValue(
//        authHeader,
//        forHTTPHeaderField: "Authorization"
//    )
//
//    let (data, _) = try await URLSession.shared.data(for: request)
//
//    let decoded = try JSONDecoder().decode(MediaResponse.self, from: data)
//
//    return decoded.data
//   }
//}
