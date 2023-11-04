import Foundation

public struct OpenGluckDevice: Hashable, Codable, Sendable {
    public let modelName: String
    public let deviceId: String

    internal enum CodingKeys: String, CodingKey {
        case modelName = "model_name"
        case deviceId = "device_id"
    }

    public init(modelName: String, deviceId: String) {
        self.modelName = modelName
        self.deviceId = deviceId
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        modelName = try values.decode(String.self, forKey: .modelName)
        deviceId = try values.decode(String.self, forKey: .deviceId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(modelName, forKey: .modelName)
        try container.encode(deviceId, forKey: .deviceId)
    }
}
