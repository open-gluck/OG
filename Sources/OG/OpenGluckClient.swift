import Foundation

public enum OpenGluckClientError: Error {
    case noData
    case uploadFailed(message: String)
}

public class OpenGluckClient {
    let hostname: String
    let token: String
    let target: String

    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    public init(hostname: String, token: String, target: String) {
        self.hostname = hostname
        self.token = token
        self.target = target
        jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom { decoder -> Date in
            let isoDateFormatter = ISO8601DateFormatter()
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self).replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
            let date = isoDateFormatter.date(from: dateStr)
            return date!
        }
        jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
    }

    private func clientHeaders() -> [String: String] {
        [
            "Authorization": "Bearer \(token)",
        ]
    }
}

public extension OpenGluckClient {
    func getLastData() async throws -> LastData? {
        return try await getLastDataIfNoneMatch(revision: nil)
    }

    private var origin: String {
        if hostname.starts(with: "http://") {
            return hostname
        } else {
            return "https://\(hostname)"
        }
    }

    func getLastDataIfNoneMatch(revision: Int64?) async throws -> LastData? {
        return try await withCheckedThrowingContinuation { continuation in
            let client = HTTPSClient(clientHeaders: clientHeaders())
            client.get(
                url: URL(string: "\(origin)/opengluck/last")!,
                ifNoneMatch: revision == nil ? nil : String(revision!),
                onComplete: { response, data in
                    guard response.statusCode != 304 else {
                        // we might not receive a 304 if we already had cached data
                        continuation.resume(returning: nil)
                        return
                    }
                    guard let data else {
                        continuation.resume(throwing: OpenGluckClientError.noData)
                        return
                    }

                    do {
                        let lastData = try self.jsonDecoder.decode(LastData.self, from: data)
                        guard revision == nil || lastData.revision != revision! else {
                            // we might not receive a 304 if we already had cached data
                            continuation.resume(returning: nil)
                            return
                        }
                        continuation.resume(returning: lastData)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                },
                onError: { error in
                    continuation.resume(throwing: error)
                }
            )
        }
    }

    func getCurrentData() async throws -> CurrentData? {
        return try await getCurrentDataIfNoneMatch(revision: nil)
    }

    func getCurrentDataIfNoneMatch(revision: Int64?) async throws -> CurrentData? {
        return try await withCheckedThrowingContinuation { continuation in
            let client = HTTPSClient(clientHeaders: clientHeaders())
            client.get(
                url: URL(string: "\(origin)/opengluck/current")!,
                ifNoneMatch: revision == nil ? nil : String(revision!),
                onComplete: { response, data in
                    guard response.statusCode != 304 else {
                        // we might not receive a 304 if we already had cached data
                        continuation.resume(returning: nil)
                        return
                    }
                    Task {
                        do {
                            // print("GOT RESPONSE \(response)")

                            guard let data else {
                                continuation.resume(throwing: OpenGluckClientError.noData)
                                return
                            }

                            let currentData = try self.jsonDecoder.decode(CurrentData.self, from: data)
                            guard revision == nil || currentData.revision != revision! else {
                                // we might not receive a 304 if we already had cached data
                                continuation.resume(returning: nil)
                                return
                            }
                            continuation.resume(returning: currentData)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                },
                onError: { error in
                    continuation.resume(throwing: error)
                }
            )
        }
    }
}

/* glucose */
public extension OpenGluckClient {
    func findGlucoseRecords(from: Date, until: Date) async throws -> [OpenGluckGlucoseRecord] {
        return try await withCheckedThrowingContinuation { continuation in
            let client = HTTPSClient(clientHeaders: clientHeaders())
            var components = URLComponents()
            components.queryItems = [
                URLQueryItem(name: "from", value: self.toISO8601(from)),
                URLQueryItem(name: "to", value: self.toISO8601(until)),
            ]
            client.get(
                url: URL(string: "\(origin)/opengluck/glucose/find\((components.string ?? "").replacing("+", with: "%2B"))")!,
                onComplete: { _, data in
                    Task {
                        do {
                            guard let data else {
                                continuation.resume(throwing: OpenGluckClientError.noData)
                                return
                            }

                            let glucoseRecords = try self.jsonDecoder.decode([OpenGluckGlucoseRecord].self, from: data)
                            continuation.resume(returning: glucoseRecords)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                },
                onError: { error in
                    continuation.resume(throwing: error)
                }
            )
        }
    }
}

/* cgm properties */
public extension OpenGluckClient {
    func getHasRealTime() async throws -> Bool? {
        return try await withCheckedThrowingContinuation { continuation in
            let client = HTTPSClient(clientHeaders: clientHeaders())
            client.get(
                url: URL(string: "\(origin)/opengluck/userdata/cgm-current-device-properties")!,
                onComplete: { _, data in
                    Task {
                        do {
                            guard let data else {
                                continuation.resume(throwing: OpenGluckClientError.noData)
                                return
                            }

                            // let json = String(decoding: data, as: UTF8.self)
                            let cgmCurrentDeviceProperties = try self.jsonDecoder.decode(CgmCurrentDeviceProperties.self, from: data)
                            continuation.resume(returning: cgmCurrentDeviceProperties.hasRealTime)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                },
                onError: { error in
                    continuation.resume(throwing: error)
                }
            )
        }
    }
}

/* episodes */
public extension OpenGluckClient {
    func getCurrentEpisode() async throws -> (Episode?, Date?) {
        return try await withCheckedThrowingContinuation { continuation in
            let client = HTTPSClient(clientHeaders: clientHeaders())
            let url = "\(origin)/opengluck/episode/current"
            client.get(
                url: URL(string: url)!,
                onComplete: { _, data in
                    Task {
                        do {
                            guard let data else {
                                // or shall we return nil?
                                return
                            }
                            let currentEpisode = try self.jsonDecoder.decode(CurrentEpisode?.self, from: data)
                            if let currentEpisode {
                                continuation.resume(returning: (currentEpisode.episode, currentEpisode.timestamp))
                            } else {
                                continuation.resume(returning: (nil, nil))
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                },
                onError: { error in
                    continuation.resume(throwing: error)
                }
            )
        }
    }
}

/* record logs */
public extension OpenGluckClient {
    private func toISO8601(_ date: Date = Date()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.string(from: date)
    }

    func recordLog(_ message: String) async {
        #if targetEnvironment(simulator)
            print("ignore(simulator): recordLog: \(message)")
        #else
            try? await withCheckedThrowingContinuation { continuation in
                let client = HTTPSClient(clientHeaders: clientHeaders())
                let payload: [String: String] = [
                    "timestamp": self.toISO8601(),
                    "message": message,
                ]
                // swiftlint:disable:next force_try
                let body = String(data: try! JSONEncoder().encode(payload), encoding: .utf8)!
                client.put(url: URL(string: "\(origin)/opengluck/userdata/log-\(target)/lpush")!, body: body.data(using: .utf8), onComplete: { _, _ in
                    continuation.resume()
                }, onError: { err in
                    print("Could not record log, ignoring: \(err)")
                    continuation.resume()
                })
            }
        #endif
    }

    func recordLog(_ message: Codable) async {
        #if targetEnvironment(simulator)
            print("ignore(simulator): recordLog: \(message)")
        #else
            try? await withCheckedThrowingContinuation { continuation in
                let client = HTTPSClient(clientHeaders: clientHeaders())
                let payload: [String: String] = [
                    "timestamp": self.toISO8601(),
                    "message": "FILLER",
                ]
                // swiftlint:disable:next force_try
                let body = String(data: try! JSONEncoder().encode(payload), encoding: .utf8)!
                    // swiftlint:disable:next force_try
                    .replacingOccurrences(of: "\"FILLER\"", with: String(data: try! JSONEncoder().encode(message), encoding: .utf8)!)
                client.put(url: URL(string: "\(origin)/opengluck/userdata/log-\(target)/lpush")!, body: body.data(using: .utf8), onComplete: { _, _ in
                    continuation.resume()
                }, onError: { err in
                    print("Could not record log, ignoring: \(err)")
                    continuation.resume()
                })
            }
        #endif
    }
}

/* APN token registration */
extension OpenGluckClient {
    private var app: String {
        #if os(iOS)
            return "iOS"
        #else
            return "watchOS"
        #endif
    }

    private var apnAppSuffix: String {
        if let apsEnvironment = MobileProvision.read()?.entitlements.apsEnvironment.rawValue.description, apsEnvironment == "production" {
            return ".production"
        }
        #if DEBUG
            return ""
        #else
            return ".production"
        #endif
    }

    public func registerPushKit(deviceToken: String) async throws {
        #if targetEnvironment(simulator)
            print("ignore(simulator): register: \(deviceToken)")
        #else
            try await withCheckedThrowingContinuation { continuation in
                let client = HTTPSClient(clientHeaders: clientHeaders())
                let timestamp = Int(Date().timeIntervalSince1970)
                let url = URL(string: "\(origin)/opengluck/userdata/apn-\(app)-pushkit\(apnAppSuffix)/zadd?score=\(timestamp)&member=\(deviceToken)")!
                client.put(url: url, onComplete: { _, _ in
                    continuation.resume()
                }, onError: { err in
                    print("Could not register device token, ignoring: \(err)")
                    continuation.resume()
                })
            }
        #endif
    }

    public func register(deviceToken: String) async throws {
        #if targetEnvironment(simulator)
            print("ignore(simulator): register: \(deviceToken)")
        #else
            try await withCheckedThrowingContinuation { continuation in
                let client = HTTPSClient(clientHeaders: clientHeaders())
                let timestamp = Int(Date().timeIntervalSince1970)
                let url = URL(string: "\(origin)/opengluck/userdata/apn-\(app)\(apnAppSuffix)/zadd?score=\(timestamp)&member=\(deviceToken)")!
                client.put(url: url, onComplete: { _, _ in
                    continuation.resume()
                }, onError: { err in
                    print("Could not register device token, ignoring: \(err)")
                    continuation.resume()
                })
            }
        #endif
    }
}

/* Upload */
public struct OpenGluckUploadResult: Codable, Sendable {
    public let revision: Int64
}

public extension OpenGluckClient {
    internal struct OpenGluckUploadRequest: Encodable {
        public let currentCgmProperties: CgmCurrentDeviceProperties?
        public let device: OpenGluckDevice?
        public let glucoseRecords: [OpenGluckGlucoseRecord]?
        public let lowRecords: [OpenGluckLowRecord]?
        public let insulinRecords: [OpenGluckInsulinRecord]?
        public let foodRecords: [OpenGluckFoodRecord]?

        // swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case currentCgmProperties = "current-cgm-device-properties"
            case device
            case glucoseRecords = "glucose-records"
            case lowRecords = "low-records"
            case insulinRecords = "insulin-records"
            case foodRecords = "food-records"
        }

        // swiftlint:enable nesting

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            if let currentCgmProperties {
                try container.encode(currentCgmProperties, forKey: .currentCgmProperties)
            }
            if let device {
                try container.encode(device, forKey: .device)
            }
            if let glucoseRecords {
                try container.encode(glucoseRecords, forKey: .glucoseRecords)
            }
            if let lowRecords {
                try container.encode(lowRecords, forKey: .lowRecords)
            }
            if let insulinRecords {
                try container.encode(insulinRecords, forKey: .insulinRecords)
            }
            if let foodRecords {
                try container.encode(foodRecords, forKey: .foodRecords)
            }
        }
    }

    func upload(currentCgmProperties: CgmCurrentDeviceProperties? = nil, device: OpenGluckDevice? = nil, glucoseRecords: [OpenGluckGlucoseRecord]? = nil, lowRecords: [OpenGluckLowRecord]? = nil, insulinRecords: [OpenGluckInsulinRecord]? = nil, foodRecords: [OpenGluckFoodRecord]? = nil) async throws -> OpenGluckUploadResult {
        try await withCheckedThrowingContinuation { continuation in
            let client = HTTPSClient(clientHeaders: clientHeaders())
            let uploadData: Data
            do {
                uploadData = try jsonEncoder.encode(OpenGluckUploadRequest(currentCgmProperties: currentCgmProperties, device: device, glucoseRecords: glucoseRecords, lowRecords: lowRecords, insulinRecords: insulinRecords, foodRecords: foodRecords))
            } catch {
                continuation.resume(throwing: error)
                return
            }
            client.post(url: URL(string: "\(origin)/opengluck/upload")!, body: uploadData, onComplete: { response, data in
                guard let data else {
                    continuation.resume(throwing: OpenGluckClientError.noData)
                    return
                }
                guard response.statusCode == 200 else {
                    let body = String(data: data, encoding: .utf8) ?? "(no body)"
                    continuation.resume(throwing: OpenGluckClientError.uploadFailed(message: "Received status code \(response.statusCode), body: \(body)"))
                    return
                }
                let result: OpenGluckUploadResult
                do {
                    result = try self.jsonDecoder.decode(OpenGluckUploadResult.self, from: data)
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

/* instant glucose */
public extension OpenGluckClient {
    internal struct OpenGluckUploadInstantGlucoseUploadRequest: Encodable {
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
                uploadData = try jsonEncoder.encode(OpenGluckUploadInstantGlucoseUploadRequest(instantGlucoseRecords: instantGlucoseRecords))
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

/* HbA1c */
public extension OpenGluckClient {
    struct OpenGluckHbA1cResult: Codable {
        public let from_date: Date
        public let to_date: Date
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
