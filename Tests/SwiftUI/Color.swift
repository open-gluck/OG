import Foundation

public struct Color: Hashable {
    let red: Double
    let green: Double
    let blue: Double

    public static let gray = Color(red: 0.5, green: 0.5, blue: 0.5)

    public init(red: Double, green: Double, blue: Double) {
        print("Color init: \(red), \(green), \(blue)")
        self.red = red
        self.green = green
        self.blue = blue
    }

    public init(white: Double) {
        red = white
        green = white
        blue = white
    }
}
