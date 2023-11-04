@preconcurrency import struct Foundation.Date

public struct OpenGluckGlucoseRecord: Hashable, Codable, Sendable {
    // this struct is not called GlucoseRecord so as not to conflict with GlucoseRecord from deps
    public let timestamp: Date
    public let mgDl: Int
    public var recordType: String?

    public init(timestamp: Date, mgDl: Int, recordType: String? = nil) {
        self.timestamp = timestamp
        self.mgDl = mgDl
        self.recordType = recordType
    }

    internal enum CodingKeys: String, CodingKey {
        case timestamp
        case mgDl
        case recordType = "record_type"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try values.decode(Date.self, forKey: .timestamp)
        mgDl = try values.decode(Int.self, forKey: .mgDl)
        recordType = try values.decodeIfPresent(String.self, forKey: .recordType)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(mgDl, forKey: .mgDl)
        if let recordType {
            try container.encode(recordType, forKey: .recordType)
        }
    }
}

/*
 public struct CurrentGlucose {
     public let currentGlucoseData: CurrentGlucoseData
     public let hasCgmRealTimeData: Bool?
 }
 */
