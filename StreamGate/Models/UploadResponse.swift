
import Foundation

//struct UploadResponse: Codable {
//    let success: Bool
//    let data: UploadData
//}
//
//struct UploadData: Codable {
//    let id: String
//    let url: String
//}

struct UploadResponse : Codable{
    let uploadId: String
    let url: String
}
