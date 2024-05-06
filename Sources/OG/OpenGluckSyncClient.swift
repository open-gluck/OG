/* A class to handle periodic synchronization with the server, with support for
 * queuing requests so that we don't have more than one concurrent operation
 * ongoing at the same time. */

import Foundation

public protocol OpenGluckSyncClientDelegate: AnyObject {
    func getClient() -> OpenGluckClient?
}

public actor OpenGluckSyncClient {
    enum SyncError: Error {
        case noCurrentData
        case noLastData
    }

    let semaphore = AsyncSemaphore()
    public private(set) var delegate: OpenGluckSyncClientDelegate?

    public func setDelegate(_ delegate: OpenGluckSyncClientDelegate) {
        self.delegate = delegate
    }

    public private(set) var lastSyncCurrentData: CurrentData?
    public private(set) var lastSyncCurrentDataStart: Date?
    public private(set) var lastSyncCurrentDataEnd: Date?

    public private(set) var lastSyncLastData: LastData?
    public private(set) var lastSyncLastDataStart: Date?
    public private(set) var lastSyncLastDataEnd: Date?

    public init(delegate: OpenGluckSyncClientDelegate? = nil) {
        self.delegate = delegate
    }

    var client: OpenGluckClient? {
        delegate!.getClient()
    }
}

public extension OpenGluckSyncClient {
    internal var durationSinceLastSyncCurrentData: TimeInterval? {
        guard let lastSyncCurrentDataEnd else {
            return nil
        }
        return -lastSyncCurrentDataEnd.timeIntervalSinceNow
    }

    func getCurrentDataIfChanged() async throws -> CurrentData? {
        await semaphore.wait()
        defer { Task { await semaphore.release() } }
        guard let client else {
            return nil
        }
        lastSyncCurrentDataStart = Date()
        let result = try await client.getCurrentDataIfNoneMatch(revision: lastSyncCurrentData?.revision)
        lastSyncCurrentDataEnd = Date()
        guard let result else {
            return nil
        }
        lastSyncCurrentData = result
        return result
    }

    func getCurrentData() async throws -> CurrentData? {
        await semaphore.wait()
        defer { Task { await semaphore.release() } }
        guard let client else {
            return nil
        }
        lastSyncCurrentDataStart = Date()
        let result = try await client.getCurrentDataIfNoneMatch(revision: lastSyncCurrentData?.revision)
        lastSyncCurrentDataEnd = Date()
        guard let result else {
            guard let lastSyncCurrentData else {
                throw SyncError.noCurrentData
            }
            return lastSyncCurrentData
        }
        lastSyncCurrentData = result
        return result
    }
}

public extension OpenGluckSyncClient {
    internal var durationSinceLastSyncLastData: TimeInterval? {
        guard let lastSyncLastDataEnd else {
            return nil
        }
        return -lastSyncLastDataEnd.timeIntervalSinceNow
    }

    func getLastDataIfChanged() async throws -> LastData? {
        await semaphore.wait()
        defer { Task { await semaphore.release() } }
        guard let client else {
            return nil
        }
        lastSyncLastDataStart = Date()
        let result = try await client.getLastDataIfNoneMatch(revision: lastSyncLastData?.revision)
        lastSyncLastDataEnd = Date()
        guard let result else {
            return nil
        }
        lastSyncLastData = result
        return result
    }

    func getLastData() async throws -> LastData? {
        await semaphore.wait()
        defer { Task { await semaphore.release() } }
        guard let client else {
            return nil
        }
        lastSyncLastDataStart = Date()
        let result = try await client.getLastDataIfNoneMatch(revision: lastSyncLastData?.revision)
        lastSyncLastDataEnd = Date()
        guard let result else {
            guard let lastSyncLastData else {
                throw SyncError.noLastData
            }
            return lastSyncLastData
        }
        lastSyncLastData = result
        return result
    }
}
