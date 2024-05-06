@testable import OG
import XCTest

final class OpenGluckSyncClientTests: XCTestCase, OpenGluckSyncClientDelegate {
    private var client: OpenGluckClient {
        let token = ProcessInfo.processInfo.environment["TEST_OPENGLUCK_TOKEN"]!
        let hostname = ProcessInfo.processInfo.environment["TEST_OPENGLUCK_HOSTNAME"]!

        return OpenGluckClient(hostname: hostname, token: token, target: "OGTests")
    }

    func getClient() -> OpenGluckClient? {
        client
    }

    func testGetCurrentData() async throws {
        let syncClient = OpenGluckSyncClient()
        await syncClient.setDelegate(self)
        let duration = await syncClient.durationSinceLastSyncCurrentData
        XCTAssertNil(duration)
        _ = try await syncClient.getCurrentData()
        let duration2 = await syncClient.durationSinceLastSyncCurrentData
        XCTAssertTrue(duration2! < 60)
    }

    func testGetLastData() async throws {
        let syncClient = OpenGluckSyncClient()
        await syncClient.setDelegate(self)
        let duration = await syncClient.durationSinceLastSyncLastData
        XCTAssertNil(duration)
        _ = try await syncClient.getLastData()
        let duration2 = await syncClient.durationSinceLastSyncLastData
        XCTAssertTrue(duration2! < 60)
    }
}
