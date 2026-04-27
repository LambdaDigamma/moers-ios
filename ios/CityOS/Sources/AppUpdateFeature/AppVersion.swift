import Foundation

public struct AppVersion: Comparable, Equatable, Sendable {
    public let rawValue: String

    private var numericComponents: [Int] {
        rawValue
            .split { !$0.isNumber }
            .compactMap { Int($0) }
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public static func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let lhsVersion = AppVersion(lhs)
        let rhsVersion = AppVersion(rhs)

        if lhsVersion < rhsVersion {
            return .orderedAscending
        }

        if lhsVersion > rhsVersion {
            return .orderedDescending
        }

        return .orderedSame
    }

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        let lhsComponents = lhs.numericComponents
        let rhsComponents = rhs.numericComponents
        let maxCount = max(lhsComponents.count, rhsComponents.count)

        for index in 0..<maxCount {
            let lhsValue = index < lhsComponents.count ? lhsComponents[index] : 0
            let rhsValue = index < rhsComponents.count ? rhsComponents[index] : 0

            if lhsValue != rhsValue {
                return lhsValue < rhsValue
            }
        }

        return false
    }
}
