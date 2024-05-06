import Foundation

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
