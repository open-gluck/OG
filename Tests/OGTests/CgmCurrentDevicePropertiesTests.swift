@testable import OG
import XCTest

final class CgmCurrentDevicePropertiesTests: XCTestCase {
    func testExample() throws {
        // XCTest Documenation
        // https://developer.apple.com/documentation/xctest
        let jsonDecoder = JSONDecoder()
        let propsTrue = try! jsonDecoder.decode(CgmCurrentDeviceProperties.self, from: "{\"has-real-time\":true}".data(using: .utf8)!)
        XCTAssert(propsTrue.hasRealTime == true)
        let propsFalse = try! jsonDecoder.decode(CgmCurrentDeviceProperties.self, from: "{\"has-real-time\":false}".data(using: .utf8)!)
        XCTAssert(propsFalse.hasRealTime == false)
    }
}
