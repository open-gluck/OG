@testable import OG
import XCTest

final class OpenGlückSyncClientTests: XCTestCase, OpenGlückSyncClientDelegate {
    private var client: OpenGlückClient {
        let token = ProcessInfo.processInfo.environment["TEST_OPENGLUCK_TOKEN"]!
        let hostname = ProcessInfo.processInfo.environment["TEST_OPENGLUCK_HOSTNAME"]!

        return OpenGlückClient(hostname: hostname, token: token, target: "OGTests")
    }

    func getClient() -> OpenGlückClient {
        client
    }

    func testGetCurrentData() async throws {
        let syncClient = OpenGlückSyncClient()
        syncClient.delegate = self
        XCTAssertNil(syncClient.durationSinceLastSyncCurrentData)
        _ = try await syncClient.getCurrentData()
        XCTAssertTrue(syncClient.durationSinceLastSyncCurrentData! < 60)
    }

    func testGetLastData() async throws {
        let syncClient = OpenGlückSyncClient()
        syncClient.delegate = self
        XCTAssertNil(syncClient.durationSinceLastSyncLastData)
        _ = try await syncClient.getLastData()
        XCTAssertTrue(syncClient.durationSinceLastSyncLastData! < 60)
    }
}
