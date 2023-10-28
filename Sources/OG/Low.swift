@preconcurrency import struct Foundation.Date
@preconcurrency import struct Foundation.UUID

public struct OpenGlückLowRecord: Hashable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let sugarInGrams: Double
    public let deleted: Bool

    public init(id: UUID, timestamp: Date, sugarInGrams: Double, deleted: Bool) {
        self.id = id
        self.timestamp = timestamp
        self.sugarInGrams = sugarInGrams
        self.deleted = deleted
    }

    internal enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case sugarInGrams = "sugar_in_grams"
        case deleted
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        timestamp = try values.decode(Date.self, forKey: .timestamp)
        sugarInGrams = try values.decode(Double.self, forKey: .sugarInGrams)
        deleted = try values.decode(Bool.self, forKey: .deleted)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(sugarInGrams, forKey: .sugarInGrams)
        try container.encode(deleted, forKey: .deleted)
    }
}
