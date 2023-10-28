import Foundation

public enum Episode: String, Codable {
    case unknown
    case disconnected
    case error
    case low
    case normal
    case high
}

public struct CurrentEpisode: Codable {
    let episode: Episode
    let timestamp: Date
}
