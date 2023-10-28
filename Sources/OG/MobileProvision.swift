import Foundation

// https://gist.githubusercontent.com/mremond/7c62e85e2f1ee6ae311ee039b959fcc0/raw/53778edd7a606a5253f811cc72c7e0066558d1a4/MobileProvision.swift

public struct Entitlements: Decodable {
    public let keychainAccessGroups: [String]
    public let getTaskAllow: Bool
    public let apsEnvironment: Environment

    private enum CodingKeys: String, CodingKey {
        case keychainAccessGroups = "keychain-access-groups"
        case getTaskAllow = "get-task-allow"
        case apsEnvironment = "aps-environment"
    }

    public enum Environment: String, Decodable {
        case development, production, disabled
    }

    init(keychainAccessGroups: [String], getTaskAllow: Bool, apsEnvironment: Environment) {
        self.keychainAccessGroups = keychainAccessGroups
        self.getTaskAllow = getTaskAllow
        self.apsEnvironment = apsEnvironment
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keychainAccessGroups: [String] = (try? container.decode([String].self, forKey: .keychainAccessGroups)) ?? []
        let getTaskAllow: Bool = (try? container.decode(Bool.self, forKey: .getTaskAllow)) ?? false
        let apsEnvironment: Environment = (try? container.decode(Environment.self, forKey: .apsEnvironment)) ?? .disabled

        self.init(keychainAccessGroups: keychainAccessGroups, getTaskAllow: getTaskAllow, apsEnvironment: apsEnvironment)
    }
}

public struct MobileProvision: Decodable {
    public var name: String
    public var appIDName: String
    public var platform: [String]
    public var isXcodeManaged: Bool? = false
    public var creationDate: Date
    public var expirationDate: Date
    public var entitlements: Entitlements

    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case appIDName = "AppIDName"
        case platform = "Platform"
        case isXcodeManaged = "IsXcodeManaged"
        case creationDate = "CreationDate"
        case expirationDate = "ExpirationDate"
        case entitlements = "Entitlements"
    }
}

// Factory methods
public extension MobileProvision {
    // Read mobileprovision file embedded in app.
    static func read() -> MobileProvision? {
        let profilePath: String? = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision")
        guard let path = profilePath else { return nil }
        return read(from: path)
    }

    // Read a .mobileprovision file on disk
    static func read(from profilePath: String) -> MobileProvision? {
        guard let plistDataString = try? NSString(contentsOfFile: profilePath,
                                                  encoding: String.Encoding.isoLatin1.rawValue) else { return nil }

        // Skip binary part at the start of the mobile provisionning profile
        let scanner = Scanner(string: plistDataString as String)
        guard scanner.scanUpToString("<plist") != nil else { return nil }

        // ... and extract plist until end of plist payload (skip the end binary part.
        guard let extractedPlist = scanner.scanUpToString("</plist>") else { return nil }

        guard let plist = extractedPlist.appending("</plist>").data(using: .isoLatin1) else { return nil }
        let decoder = PropertyListDecoder()
        do {
            let provision = try decoder.decode(MobileProvision.self, from: plist)
            return provision
        } catch {
            return nil
        }
    }
}
