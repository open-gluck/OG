import SwiftUI

public final class OGUI {
    private init() {}

    public static var thresholdsDelegate: OGUIThresholdsDelegate = .init()

    public static var thresholdNormalLow: Double { thresholdsDelegate.normalLow }
    public static var thresholdNormalHigh: Double { thresholdsDelegate.normalHigh }
    public static var thresholdLow: Double { thresholdsDelegate.low }
    public static var thresholdHigh: Double { thresholdsDelegate.high }
    public static var thresholdHighVeryHigh: Double { thresholdsDelegate.highVeryHigh }

    public static let lowColor = Color(red: 229 / 256, green: 0 / 256, blue: 5 / 256)
    public static let lowColorText = Color(red: 255 / 256, green: 255 / 256, blue: 255 / 256)

    public static let normalColor = Color(red: 17 / 256, green: 156 / 256, blue: 12 / 256)
    public static let normalColorText = Color(red: 255 / 256, green: 255 / 256, blue: 255 / 256)

    public static let highColor = Color(red: 254 / 256, green: 149 / 256, blue: 4 / 256)
    public static let highColorText = Color(red: 255 / 256, green: 255 / 256, blue: 255 / 256)

    public static let veryHighColor = Color(red: 255 / 256, green: 52 / 256, blue: 0 / 256)
    public static let veryHighColorText = Color(red: 255 / 256, green: 255 / 256, blue: 255 / 256)

    public static func glucoseTextColor(mgDl: Double) -> Color {
        if mgDl < thresholdNormalLow {
            return Self.lowColorText
        } else if mgDl <= thresholdNormalHigh {
            return Self.normalColorText
        } else if mgDl > thresholdHighVeryHigh {
            return Self.veryHighColorText
        } else {
            return Self.highColorText
        }
    }

    public static func glucoseColor(mgDl: Double) -> Color {
        if mgDl < thresholdNormalLow {
            return Self.lowColor
        } else if mgDl <= thresholdNormalHigh {
            return Self.normalColor
        } else if mgDl > thresholdHighVeryHigh {
            return Self.veryHighColor
        } else {
            return Self.highColor
        }
    }

    private static func gray(_ value: Double) -> Color {
        let rgb = value / 256
        return Color(red: rgb, green: rgb, blue: rgb)
    }

    public static func timebarsPastColor(forColorScheme colorScheme: ColorScheme) -> Color { colorScheme == .dark ? Color(white: 0.55) : Color(white: 0.5) }
    public static func timebarsFutureColorDeprecated(forColorScheme colorScheme: ColorScheme) -> Color { colorScheme == .light ? gray(0xC0) : gray(0x60) }
    public static func timebarsForecastColor(forColorScheme colorScheme: ColorScheme) -> Color { colorScheme == .dark ? Color(white: 0.7) : Color(white: 0.4) }
    public static func nowColor(forColorScheme colorScheme: ColorScheme) -> Color { colorScheme == .light ? gray(0xC0) : gray(0x60) }
    public static func nowTextColor(forColorScheme colorScheme: ColorScheme) -> Color { colorScheme == .light ? gray(0x4F) : gray(0xD6) }
}
