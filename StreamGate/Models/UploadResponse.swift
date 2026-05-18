
//import Foundation
//
//struct UploadResponse : Codable{
//    let uploadId: String
//    let url: String
//}

import Foundation

struct CreateDirectUploadResponse: Decodable {
    let success: Bool
    let data: UploadData
}

struct UploadData: Decodable {
    let uploadId: String
    let url: String
}
