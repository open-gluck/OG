@testable import OG
import XCTest

final class AsyncSemaphoreTests: XCTestCase {
    var start1: Date? = nil
    var start2: Date? = nil
    var end1: Date? = nil
    var end2: Date? = nil
    func testAsyncSemaphore() async throws {
        let s = AsyncSemaphore()

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await s.wait()
                defer { Task { await s.release() } }
                self.start1 = Date()
                // try! await Task.sleep(nanoseconds: 100_000_000)
                try! await Task.sleep(nanoseconds: 1_000_000_000)
                self.end1 = Date()
            }
            group.addTask {
                await s.wait()
                defer { Task { await s.release() } }
                self.start2 = Date()
                // try! await Task.sleep(nanoseconds: 100_000_000)
                try! await Task.sleep(nanoseconds: 1_000_000_000)
                self.end2 = Date()
            }
        }

        XCTAssertNotNil(start1)
        XCTAssertNotNil(start2)
        XCTAssertNotNil(end1)
        XCTAssertNotNil(end2)
        XCTAssertTrue(start1! < end1!)
        XCTAssertTrue(start2! < end2!)

        if start1! < start2! {
            XCTAssertTrue(end1! < start2!)
        } else {
            XCTAssertTrue(end2! < start1!)
        }
    }
}
