public final class CgmCurrentDeviceProperties: Sendable, Codable {
    public let hasRealTime: Bool?
    public let realTimeInterval: Int?

    public init(hasRealTime: Bool?, realTimeInterval: Int?) {
        self.hasRealTime = hasRealTime
        self.realTimeInterval = realTimeInterval
    }

    enum CodingKeys: String, CodingKey {
        case hasRealTime = "has-real-time"
        case realTimeInterval = "real-time-interval"
    }

    public required init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        hasRealTime = try container.decodeIfPresent(Bool.self, forKey: CodingKeys.hasRealTime)
        realTimeInterval = try container.decodeIfPresent(Int.self, forKey: CodingKeys.realTimeInterval)
    }

    public func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hasRealTime, forKey: CodingKeys.hasRealTime)
        try container.encode(realTimeInterval, forKey: CodingKeys.realTimeInterval)
    }
}
