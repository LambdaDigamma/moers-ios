import Foundation

nonisolated public enum EventAttendanceMode: String, CaseIterable, Hashable, Sendable {
    case offline
    case online
    case mixed

    public var title: String {
        switch self {
        case .offline:
            String(localized: "In Person", bundle: .module)
        case .online:
            String(localized: "Online", bundle: .module)
        case .mixed:
            String(localized: "Hybrid", bundle: .module)
        }
    }

    public static func title(for value: String) -> String {
        Self(rawValue: value)?.title ?? value
    }
}
