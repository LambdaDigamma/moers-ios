import Foundation

public struct AppStoreUpdate: Equatable, Identifiable, Sendable {
    public let version: String
    public let storeURL: URL

    public var id: String { version }

    public init(version: String, storeURL: URL) {
        self.version = version
        self.storeURL = storeURL
    }
}

public enum AppStoreUpdateStatus: Equatable, Sendable {
    case newerVersionInstalled
    case upToDate
    case updateAvailable(AppStoreUpdate)
}

