import Foundation

protocol OGUIThresholdsDelegate {
    // when the blood glucose is below normalHigh, it is still considered
    // in the normal range until it reaches low, but in the low range
    public var normalLow: Double

    // when the blood glucose is above normalHigh, it is still considered
    // in the normal range until it reaches high, but in the high range
    public var normalHigh: Double

    // when the blood glucose is below low, it is considered low
    public var low: Double

    // when the blood glucose is at or above high, it is considered high
    public var high: Double

    // when the blood glucose is at or above highVeryHigh, it is considered
    // very high
    public var highVeryHigh: Double
}
