import Foundation
import Events

nonisolated enum UserScheduleDay: Hashable, Sendable {
    case scheduled(Date)
    case unscheduled

    init(startDate: Date?) {
        if let components = startDate.getDateForGroup(acceptedOffset: 3 * 60 * 60),
           let date = Calendar.autoupdatingCurrent.date(from: components) {
            self = .scheduled(date)
        } else {
            self = .unscheduled
        }
    }

    var date: Date? {
        guard case .scheduled(let date) = self else { return nil }
        return date
    }
}
