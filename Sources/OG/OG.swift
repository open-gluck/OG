// swiftlint:disable:next type_name
public final class OG {
    private init() {}

    public static var apnAppSuffix: String {
        if let apsEnvironment = MobileProvision.read()?.entitlements.apsEnvironment.rawValue.description, apsEnvironment == "production" {
            return ".production"
        }
        #if DEBUG
            return ""
        #else
            return ".production"
        #endif
    }
}
