@testable import DiablyLib
import XCTest

final class DiablyTests: XCTestCase {
    func testExample() throws {
        // XCTest Documenation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

        XCTAssert(DiablyLib.glucoseColor(mgDl: 234) == DiablyLib.highColor)
        XCTAssert(DiablyLib.glucoseColor(mgDl: 123) == DiablyLib.normalColor)
        XCTAssert(DiablyLib.glucoseColor(mgDl: 42) == DiablyLib.lowColor)

        // asserts the version looks like a version, matching the regexp ^v[0-9]+\.[0-9]+\.[0-9]+$
        let version = DiablyLib.VERSION
        let regex = try NSRegularExpression(pattern: "^v[0-9]+\\.[0-9]+\\.[0-9]+$")
        let range = NSRange(location: 0, length: version.utf16.count)
        XCTAssertNotNil(regex.firstMatch(in: version, options: [], range: range))
    }
}
