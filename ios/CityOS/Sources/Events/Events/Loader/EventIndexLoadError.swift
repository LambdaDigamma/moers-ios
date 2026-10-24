import Foundation

nonisolated public struct EventIndexLoadError: LocalizedError, Sendable {
    public let events: [Event]
    public let failedPages: [Int]

    public init(events: [Event], failedPages: [Int]) {
        self.events = events
        self.failedPages = failedPages
    }

    public var errorDescription: String? {
        String(localized: "Some events could not be loaded. Try again.", bundle: .module)
    }
}
