struct MediaResponse: Codable {
    let success: Bool
    let data: MediaData
}

struct MediaData: Codable {
    let id: String
    let status: String
    let playbackIds: [PlaybackId]?
}

struct PlaybackId: Codable {
    let id: String
}
