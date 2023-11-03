import Foundation

public protocol OGUIThresholdsDelegate {
    // when the blood glucose is below normalHigh, it is still considered
    // in the normal range until it reaches low, but in the low range
    var normalLow: Double { get }

    // when the blood glucose is above normalHigh, it is still considered
    // in the normal range until it reaches high, but in the high range
    var normalHigh: Double { get }

    // when the blood glucose is below low, it is considered low
    var low: Double { get }

    // when the blood glucose is at or above high, it is considered high
    var high: Double { get }

    // when the blood glucose is at or above highVeryHigh, it is considered
    // very high
    var highVeryHigh: Double { get }
}
