import Foundation

// https://forums.swift.org/t/semaphore-alternatives-for-structured-concurrency/59353/2

public actor AsyncSemaphore {
    private var count: Int
    private var waiters: [CheckedContinuation<Void, Never>] = []

    public init(count: Int = 1) {
        self.count = count
    }

    public func wait() async {
        count -= 1
        if count >= 0 { return }
        await withCheckedContinuation {
            waiters.append($0)
        }
    }

    public func release(count: Int = 1) {
        assert(count >= 1)
        self.count += count
        for _ in 0 ..< count {
            if waiters.isEmpty { return }
            waiters.removeFirst().resume()
        }
    }
}
