
public class DefaultOGUIThresholdsDelegate: OGUIThresholdsDelegate {
    public init() {}

    public static let defaultNormalLow: Double = 70.0
    public static let defaultNormalHigh: Double = 150.0
    public static let defaultLow: Double = 70.0
    public static let defaultHigh: Double = 170.0
    public static let defaultHighVeryHigh: Double = 240.0

    // when the blood glucose is below normalHigh, it is still considered
    // in the normal range until it reaches low, but in the low range
    public var normalLow: Double {
        Self.defaultNormalLow
    }

    // when the blood glucose is above normalHigh, it is still considered
    // in the normal range until it reaches high, but in the high range
    public var normalHigh: Double {
        Self.defaultNormalHigh
    }

    // when the blood glucose is below low, it is considered low
    public var low: Double {
        Self.defaultLow
    }

    // when the blood glucose is at or above high, it is considered high
    public var high: Double {
        Self.defaultHigh
    }

    // when the blood glucose is at or above highVeryHigh, it is considered
    // very high
    public var highVeryHigh: Double {
        Self.defaultHighVeryHigh
    }
}
