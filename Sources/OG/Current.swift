@preconcurrency import struct Foundation.Date

public struct CurrentData: Codable, Sendable {
    public let currentGlucoseRecord: OpenGluckGlucoseRecord?
    public let currentInstantGlucoseRecord: OpenGluckInstantGlucoseRecord?
    public let lastHistoricGlucoseRecord: OpenGluckGlucoseRecord?
    public let currentEpisode: Episode
    public let currentEpisodeTimestamp: Date
    public let revision: Int64
    public let hasCgmRealTimeData: Bool

    enum CodingKeys: String, CodingKey {
        case currentGlucoseRecord = "current_glucose_record"
        case currentInstantGlucoseRecord = "current_instant_glucose_record"
        case lastHistoricGlucoseRecord = "last_historic_glucose_record"
        case revision
        case currentEpisode = "current_episode"
        case currentEpisodeTimestamp = "current_episode_timestamp"
        case hasCgmRealTimeData = "has_cgm_real_time_data"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentGlucoseRecord = try container.decodeIfPresent(OpenGluckGlucoseRecord.self, forKey: .currentGlucoseRecord)
        currentInstantGlucoseRecord = try container.decodeIfPresent(OpenGluckInstantGlucoseRecord.self, forKey: .currentInstantGlucoseRecord)
        currentEpisode = try container.decodeIfPresent(Episode.self, forKey: .currentEpisode) ?? .unknown
        currentEpisodeTimestamp = try container.decodeIfPresent(Date.self, forKey: .currentEpisodeTimestamp) ?? Date(timeIntervalSince1970: 0)
        lastHistoricGlucoseRecord = try container.decodeIfPresent(OpenGluckGlucoseRecord.self, forKey: .lastHistoricGlucoseRecord)
        revision = try container.decodeIfPresent(Int64.self, forKey: .revision) ?? -1
        hasCgmRealTimeData = try container.decode(Bool.self, forKey: .hasCgmRealTimeData)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let currentGlucoseRecord {
            try container.encode(currentGlucoseRecord, forKey: .currentGlucoseRecord)
        }
        if let currentInstantGlucoseRecord {
            try container.encode(currentInstantGlucoseRecord, forKey: .currentInstantGlucoseRecord)
        }
        try container.encode(currentEpisode, forKey: .currentEpisode)
        try container.encode(currentEpisodeTimestamp, forKey: .currentEpisodeTimestamp)
        if let lastHistoricGlucoseRecord {
            try container.encode(lastHistoricGlucoseRecord, forKey: .lastHistoricGlucoseRecord)
        }
        try container.encode(revision, forKey: .revision)
        try container.encode(hasCgmRealTimeData, forKey: .hasCgmRealTimeData)
    }
}
