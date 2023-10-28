import Foundation
import OG
import SwiftUI

public enum DiablySandbox {
    public static func getRecordMgDl(record: OpenGlückGlucoseRecord) -> Int {
        return record.mgDl
    }

    public static func getSomeMgDl() -> Int {
        let record = OpenGlückGlucoseRecord(timestamp: Date(), mgDl: 123)
        return Self.getRecordMgDl(record: record)
    }

    public static func getSomeColor() -> Color {
        return Color(red: 1, green: 0.5, blue: 0)
    }
}
