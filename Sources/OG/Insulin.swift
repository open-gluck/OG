@preconcurrency import struct Foundation.Date
@preconcurrency import struct Foundation.UUID

public struct OpenGlückInsulinRecord: Hashable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let units: Int
    public let deleted: Bool

    public init(id: UUID, timestamp: Date, units: Int, deleted: Bool) {
        self.id = id
        self.timestamp = timestamp
        self.units = units
        self.deleted = deleted
    }

    internal enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case units
        case deleted
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        timestamp = try values.decode(Date.self, forKey: .timestamp)
        units = try values.decode(Int.self, forKey: .units)
        deleted = try values.decode(Bool.self, forKey: .deleted)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(units, forKey: .units)
        try container.encode(deleted, forKey: .deleted)
    }
}
