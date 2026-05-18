
import Foundation

struct CreateDirectUploadRequest: Encodable {
    
    let corsOrigin: String
    let pushMediaSettings: PushMediaSettings
    let newAssetSettings: NewAssetSettings
    
    struct PushMediaSettings: Encodable {
    }
    
    struct NewAssetSettings: Encodable {
        let accessPolicy: String
        let generateSubtitles: Bool
        let normalizeAudio: Bool
        let maxResolution: String
        let mediaQuality: String
    }
}
