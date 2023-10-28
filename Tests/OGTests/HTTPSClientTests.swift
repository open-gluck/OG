@testable import OG
import XCTest

final class HTTPSClientTests: XCTestCase {
    func testPing() async throws {
        let client = HTTPSClient()
        return try await withCheckedThrowingContinuation { continuation in
            client.get(
                url: URL(string: "https://www.example.com")!,
                onComplete: { response, _ in
                    XCTAssertEqual(response.statusCode, 200)
                    continuation.resume()
                },
                onError: { error in
                    continuation.resume(throwing: error)
                }
            )
        }
    }
}
