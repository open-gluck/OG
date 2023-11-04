import Foundation

public struct LastData: Codable, Sendable {
    public let revision: Int64
    public let glucoseRecords: [OpenGluckGlucoseRecord]?
    public let lowRecords: [OpenGluckLowRecord]?
    public let insulinRecords: [OpenGluckInsulinRecord]?
    public let foodRecords: [OpenGluckFoodRecord]?

    enum CodingKeys: String, CodingKey {
        case revision
        case glucoseRecords = "glucose-records"
        case lowRecords = "low-records"
        case insulinRecords = "insulin-records"
        case foodRecords = "food-records"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        revision = try container.decode(Int64.self, forKey: .revision)
        glucoseRecords = try container.decode([OpenGluckGlucoseRecord].self, forKey: .glucoseRecords)
        lowRecords = try container.decodeIfPresent([OpenGluckLowRecord].self, forKey: .lowRecords) ?? []
        insulinRecords = try container.decodeIfPresent([OpenGluckInsulinRecord].self, forKey: .insulinRecords) ?? []
        foodRecords = try container.decodeIfPresent([OpenGluckFoodRecord].self, forKey: .foodRecords) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(revision, forKey: .revision)
        try container.encode(glucoseRecords, forKey: .glucoseRecords)
        try container.encode(lowRecords, forKey: .lowRecords)
        try container.encode(insulinRecords, forKey: .insulinRecords)
        try container.encode(foodRecords, forKey: .foodRecords)
    }
}
