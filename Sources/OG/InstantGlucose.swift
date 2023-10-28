import Foundation

public struct OpenGlückInstantGlucoseRecord: Hashable, Codable {
    public let timestamp: Date
    public let mgDl: Int
    public let modelName: String
    public let deviceId: String

    public init(timestamp: Date, mgDl: Int, modelName: String, deviceId: String) {
        self.timestamp = timestamp
        self.mgDl = mgDl
        self.modelName = modelName
        self.deviceId = deviceId
    }

    internal enum CodingKeys: String, CodingKey {
        case timestamp
        case mgDl
        case modelName = "model_name"
        case deviceId = "device_id"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try values.decode(Date.self, forKey: .timestamp)
        mgDl = try values.decode(Int.self, forKey: .mgDl)
        modelName = try values.decode(String.self, forKey: .modelName)
        deviceId = try values.decode(String.self, forKey: .deviceId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(mgDl, forKey: .mgDl)
        try container.encode(modelName, forKey: .modelName)
        try container.encode(deviceId, forKey: .deviceId)
    }
}
