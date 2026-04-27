import Foundation

public final class AppUpdatePersistence: @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let keyPrefix: String

    public init(userDefaults: UserDefaults = .standard, keyPrefix: String = "app_update_feature") {
        self.userDefaults = userDefaults
        self.keyPrefix = keyPrefix
    }

    public func didDismissBanner(for version: String) -> Bool {
        userDefaults.bool(forKey: dismissalKey(for: version))
    }

    public func dismissBanner(for version: String) {
        userDefaults.set(true, forKey: dismissalKey(for: version))
    }

    private func dismissalKey(for version: String) -> String {
        "\(keyPrefix).banner.dismissed.\(version)"
    }
}

