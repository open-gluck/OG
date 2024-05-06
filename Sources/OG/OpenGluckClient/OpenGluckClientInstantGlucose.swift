import Foundation

/* instant glucose */
public extension OpenGluckClient {
    internal struct OpenGluckInstantGlucoseUploadRequest: Encodable {
        public let instantGlucoseRecords: [OpenGluckInstantGlucoseRecord]

        // swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case instantGlucoseRecords = "instant-glucose-records"
        }

        // swiftlint:enable nesting

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(instantGlucoseRecords, forKey: .instantGlucoseRecords)
        }
    }

    struct OpenGluckUploadInstantGlucoseResult: Codable {
        public let success: Bool
        public let status: String
    }

    func upload(instantGlucoseRecords: [OpenGluckInstantGlucoseRecord]) async throws -> OpenGluckUploadInstantGlucoseResult {
        try await withCheckedThrowingContinuation { continuation in
            let client = HTTPSClient(clientHeaders: clientHeaders())
            let uploadData: Data
            do {
                uploadData = try jsonEncoder.encode(OpenGluckInstantGlucoseUploadRequest(instantGlucoseRecords: instantGlucoseRecords))
            } catch {
                continuation.resume(throwing: error)
                return
            }
            client.post(url: URL(string: "\(origin)/opengluck/instant-glucose/upload")!, body: uploadData, onComplete: { response, data in
                guard let data else {
                    continuation.resume(throwing: OpenGluckClientError.noData)
                    return
                }
                guard response.statusCode == 200 else {
                    let body = String(data: data, encoding: .utf8) ?? "(no body)"
                    continuation.resume(throwing: OpenGluckClientError.uploadFailed(message: "Received status code \(response.statusCode), body: \(body)"))
                    return
                }
                let result: OpenGluckUploadInstantGlucoseResult
                do {
                    result = try self.jsonDecoder.decode(OpenGluckUploadInstantGlucoseResult.self, from: data)
                } catch {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: result)
            }, onError: { err in
                print("Could not upload: \(err)")
                continuation.resume(throwing: err)
            })
        }
    }
}
