import Foundation

nonisolated public extension Event {
    var resolvedAttendanceMode: String? {
        if attendanceMode == EventAttendanceMode.mixed.rawValue || attendanceMode == "hybrid" {
            return EventAttendanceMode.mixed.rawValue
        }
        if isOnline {
            return EventAttendanceMode.online.rawValue
        }
        return attendanceMode
    }

    var attendanceTitle: String? {
        resolvedAttendanceMode.map(EventAttendanceMode.title(for:))
    }
}
