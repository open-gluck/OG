@preconcurrency import struct Foundation.Date
@preconcurrency import struct Foundation.UUID

public enum OpenGlückGlucoseSpeed: String, Codable, Sendable {
    case auto
    case custom
    case fast
    case medium
    case slow
}

public struct OpenGlückPossibleCompressorsValue: Hashable, Codable, Sendable {
    public let glucoseSpeed: OpenGlückGlucoseSpeed
    public let comp: Double?

    public init(glucoseSpeed: OpenGlückGlucoseSpeed, comp: Double?) {
        self.glucoseSpeed = glucoseSpeed
        self.comp = comp
    }

    internal enum CodingKeys: String, CodingKey {
        case glucoseSpeed = "glucose_speed"
        case comp
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        glucoseSpeed = try values.decode(OpenGlückGlucoseSpeed.self, forKey: .glucoseSpeed)
        comp = try values.decodeIfPresent(Double.self, forKey: .comp)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(glucoseSpeed, forKey: .glucoseSpeed)
        try container.encodeIfPresent(comp, forKey: .comp)
    }
}

public struct OpenGlückFoodRecord: Hashable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let deleted: Bool
    public let name: String
    public let carbs: Double?
    public let comps: OpenGlückPossibleCompressorsValue
    public let recordUntil: Date?
    public let rememberRecording: Bool

    public init(id: UUID, timestamp: Date, deleted: Bool, name: String, carbs: Double?, comps: OpenGlückPossibleCompressorsValue, recordUntil: Date?, rememberRecording: Bool) {
        self.id = id
        self.timestamp = timestamp
        self.deleted = deleted
        self.name = name
        self.carbs = carbs
        self.comps = comps
        self.recordUntil = recordUntil
        self.rememberRecording = rememberRecording
    }

    internal enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case deleted
        case name
        case carbs
        case comps
        case recordUntil = "record_until"
        case rememberRecording = "remember_recording"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        timestamp = try values.decode(Date.self, forKey: .timestamp)
        deleted = try values.decode(Bool.self, forKey: .deleted)
        name = try values.decode(String.self, forKey: .name)
        carbs = try values.decodeIfPresent(Double.self, forKey: .carbs)
        comps = try values.decode(OpenGlückPossibleCompressorsValue.self, forKey: .comps)
        recordUntil = try values.decodeIfPresent(Date.self, forKey: .recordUntil)
        rememberRecording = try values.decode(Bool.self, forKey: .rememberRecording)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(deleted, forKey: .deleted)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(carbs, forKey: .carbs)
        try container.encode(comps, forKey: .comps)
        try container.encodeIfPresent(recordUntil, forKey: .recordUntil)
        try container.encode(rememberRecording, forKey: .rememberRecording)
    }
}
