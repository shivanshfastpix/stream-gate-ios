import Foundation

enum UploadServiceError: LocalizedError {
    
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case decodingFailed
    case invalidUploadURL
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."
            
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
            
        case .decodingFailed:
            return "Failed to decode server response."
            
        case .invalidUploadURL:
            return "Invalid upload URL received."
        }
    }
}
