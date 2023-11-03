@testable import OG
import XCTest

final class OpenGlückTests: XCTestCase {
    private var client: OpenGlückClient {
        let token = ProcessInfo.processInfo.environment["TEST_OPENGLUCK_TOKEN"]!
        let hostname = ProcessInfo.processInfo.environment["TEST_OPENGLUCK_HOSTNAME"]!

        return OpenGlückClient(hostname: hostname, token: token, target: "OGTests")
    }

    func testLastData() async throws {
        _ = try await client.getLastData()
    }

    func testHasRealTime() async throws {
        _ = try await client.getHasRealTime()
    }

    func testGetCurrentEpisode() async throws {
        _ = try await client.getCurrentEpisode()
    }

    func testGetCurrentData() async throws {
        let currentData = try await client.getCurrentData()!
        XCTAssertNotNil(currentData)
        let revision = currentData.revision
        let currentDataIfNoneMatch = try await client.getCurrentDataIfNoneMatch(revision: revision)
        XCTAssertNil(currentDataIfNoneMatch)
    }

    func testRecordLog() async throws {
        _ = await client.recordLog("Test Log")
        _ = await client.recordLog(["This is": "a test log"])
    }

    func testUpload() async throws {
        let timestampOneHourAgo = Date().addingTimeInterval(-3600)
        let timestampTwoHoursAgo = Date().addingTimeInterval(-2 * 3600)
        let lowRecords: [OpenGlückLowRecord] = [.init(id: UUID(), timestamp: timestampOneHourAgo, sugarInGrams: 20, deleted: false)]
        let insulinRecords: [OpenGlückInsulinRecord] = [.init(id: UUID(), timestamp: timestampTwoHoursAgo, units: 5, deleted: false)]
        let result = try await client.upload(lowRecords: lowRecords, insulinRecords: insulinRecords)
        let revision = result.revision
        XCTAssertGreaterThanOrEqual(revision, 0)

        // try to upload again, we should still receive the same revision
        let result2 = try await client.upload(lowRecords: lowRecords, insulinRecords: insulinRecords)
        XCTAssertEqual(result2.revision, revision)

        // check if the last data is as expected
        let lastData = try await client.getLastData()!
        XCTAssertNotNil(lastData.lowRecords)
        XCTAssertNotNil(lastData.insulinRecords)
        let lastDataLowRecords = lastData.lowRecords!
        let lastDataInsulinRecords = lastData.insulinRecords!.filter { !$0.deleted }
        XCTAssertGreaterThan(lastDataLowRecords.count, 0)
        XCTAssertGreaterThan(lastDataInsulinRecords.count, 0)
        let firstLowRecord = lastDataLowRecords.first!
        let firstInsulinRecord = lastDataInsulinRecords.first!
        XCTAssertEqual(firstLowRecord.sugarInGrams, 20)
        XCTAssertLessThan(firstLowRecord.timestamp.timeIntervalSince(timestampOneHourAgo), 1)
        XCTAssertEqual(firstInsulinRecord.units, 5)
        XCTAssertLessThan(firstInsulinRecord.timestamp.timeIntervalSince(timestampTwoHoursAgo), 1)
    }
}
