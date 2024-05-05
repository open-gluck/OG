import Foundation

/* HbA1c */
public extension OpenGluckClient {
    struct OpenGluckHbA1cResult: Codable {
        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case fromDate = "from_date"
            case toDate = "to_date"
            case hba1c
        }

        public let fromDate: Date
        public let toDate: Date
        public let hba1c: Double?
    }

    func getHbA1c(from fromDate: Date, to toDate: Date) async throws -> OpenGluckHbA1cResult {
        print("Getting HbA1c from \(fromDate) to \(toDate)")
        return try await withCheckedThrowingContinuation { [self] continuation in
            let client = HTTPSClient(clientHeaders: clientHeaders())
            var components = URLComponents()
            components.queryItems = [
                URLQueryItem(name: "from", value: self.toISO8601(fromDate)),
                URLQueryItem(name: "to", value: self.toISO8601(toDate)),
            ]
            client.post(url: URL(string: "\(origin)/opengluck/hba1c\(components.string ?? "")")!, onComplete: { response, data in
                guard let data else {
                    continuation.resume(throwing: OpenGluckClientError.noData)
                    return
                }
                guard response.statusCode == 200 else {
                    let body = String(data: data, encoding: .utf8) ?? "(no body)"
                    continuation.resume(throwing: OpenGluckClientError.uploadFailed(message: "Received status code \(response.statusCode), body: \(body)"))
                    return
                }
                let result: OpenGluckHbA1cResult
                do {
                    result = try self.jsonDecoder.decode(OpenGluckHbA1cResult.self, from: data)
                } catch {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: result)
            }, onError: { err in
                print("Could not get HbA1c: \(err)")
                continuation.resume(throwing: err)
            })
        }
    }

    func getHbA1cToday() async throws -> OpenGluckHbA1cResult {
        let now = Date()
        let midnight = Calendar.current.startOfDay(for: now)
        return try await getHbA1c(from: midnight, to: now)
    }

    func getHbA1cLast24Hours() async throws -> OpenGluckHbA1cResult {
        let now = Date()
        let fromDate = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        return try await getHbA1c(from: fromDate, to: now)
    }

    func getHbA1cYesterday() async throws -> OpenGluckHbA1cResult {
        let now = Date()
        let midnight = Calendar.current.startOfDay(for: now)
        let fromDate = Calendar.current.date(byAdding: .day, value: -1, to: midnight)!
        return try await getHbA1c(from: fromDate, to: midnight)
    }

    func getHbA1cLast7Days() async throws -> OpenGluckHbA1cResult {
        let now = Date()
        let midnight = Calendar.current.startOfDay(for: now)
        let fromDate = Calendar.current.date(byAdding: .day, value: -7, to: midnight)!
        return try await getHbA1c(from: fromDate, to: midnight)
    }

    func getHbA1cLast30Days() async throws -> OpenGluckHbA1cResult {
        let now = Date()
        let midnight = Calendar.current.startOfDay(for: now)
        let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: midnight)!
        return try await getHbA1c(from: fromDate, to: midnight)
    }

    func getHbA1cLast90Days() async throws -> OpenGluckHbA1cResult {
        let now = Date()
        let midnight = Calendar.current.startOfDay(for: now)
        let fromDate = Calendar.current.date(byAdding: .day, value: -90, to: midnight)!
        return try await getHbA1c(from: fromDate, to: midnight)
    }
}
