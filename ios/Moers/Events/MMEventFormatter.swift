//
//  MMEventFormatter.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation
import MMEvents

nonisolated enum MMEventFormatter {
    static func location(for event: Event) -> String? {
        event.extras?.location ?? event.place?.name
    }

    static func organizer(for event: Event) -> String? {
        event.organisationName ?? event.extras?.organizer
    }

    static func subtitle(for event: Event, calendar: Calendar = .autoupdatingCurrent) -> String {
        let location = location(for: event)
        let date = dateRange(for: event, calendar: calendar)

        return [location, date].compactMap { value in
            guard let value, !value.isEmpty else { return nil }
            return value
        }.joined(separator: " · ")
    }

    static func dateRange(for event: Event, calendar: Calendar = .autoupdatingCurrent) -> String? {
        guard let startDate = event.startDate else { return nil }

        if !event.showsDateComponent {
            return nil
        }

        if !event.showsTimeComponent {
            return DateFormatter.mmEventString(from: startDate, dateFormat: "E, dd.MM.")
        }

        guard let endDate = event.endDate else {
            return DateFormatter.mmEventString(from: startDate, dateFormat: "E, dd.MM. HH:mm")
        }

        if calendar.isDate(startDate, inSameDayAs: endDate) {
            let start = DateFormatter.mmEventString(from: startDate, dateFormat: "E, dd.MM. HH:mm")
            let end = DateFormatter.mmEventString(from: endDate, dateFormat: "HH:mm")

            return "\(start) - \(end)"
        }

        let start = DateFormatter.mmEventString(from: startDate, dateFormat: "E, dd.MM. HH:mm")
        let end = DateFormatter.mmEventString(from: endDate, dateFormat: "E, dd.MM. HH:mm")

        return "\(start) - \(end)"
    }

    static func dayBadge(for event: Event, calendar: Calendar = .autoupdatingCurrent) -> (day: String, month: String)? {
        guard event.showsDateComponent, let startDate = event.startDate else { return nil }
        return (
            DateFormatter.mmEventString(from: startDate, dateFormat: "dd"),
            DateFormatter.mmEventString(from: startDate, dateFormat: "MMM")
        )
    }

    static func compactDate(for event: Event, calendar: Calendar = .autoupdatingCurrent) -> String? {
        guard event.showsDateComponent, let startDate = event.startDate else { return nil }

        if !event.showsTimeComponent {
            return DateFormatter.mmEventString(from: startDate, dateFormat: "dd.MM.")
        }

        if calendar.isDateInToday(startDate) {
            return DateFormatter.mmEventString(from: startDate, dateFormat: "HH:mm")
        }

        if calendar.isDateInTomorrow(startDate) {
            let time = DateFormatter.mmEventString(from: startDate, dateFormat: "HH:mm")
            return String(localized: "Tomorrow \(time)")
        }

        return DateFormatter.mmEventString(from: startDate, dateFormat: "dd.MM. HH:mm")
    }

    static func overlapsToday(_ event: Event, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        overlapsDay(event, dayOffset: 0, calendar: calendar)
    }

    static func overlapsDay(_ event: Event, dayOffset: Int, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        let dayStart = calendar.startOfDay(for: Date())
        guard let targetStart = calendar.date(byAdding: .day, value: dayOffset, to: dayStart),
              let targetEnd = calendar.date(byAdding: .day, value: 1, to: targetStart),
              let startDate = event.startDate else { return false }

        let endDate = event.endDate ?? startDate
        return startDate < targetEnd && endDate >= targetStart
    }

    static func isNextDaysEvent(_ event: Event, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        let today = calendar.startOfDay(for: Date())
        guard let startDate = event.startDate,
              let twoDaysOut = calendar.date(byAdding: .day, value: 2, to: today),
              let sevenDaysOut = calendar.date(byAdding: .day, value: 7, to: today) else { return false }

        return startDate >= twoDaysOut && startDate < sevenDaysOut
    }

    static func isFutureEvent(_ event: Event, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        guard let startDate = event.startDate,
              let sevenDaysOut = calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: Date())) else { return false }

        return startDate >= sevenDaysOut
    }

    static func isWeekendEvent(_ event: Event, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        guard let startDate = event.startDate else { return false }
        let weekday = calendar.component(.weekday, from: startDate)
        return weekday == 1 || weekday == 7
    }

    static func searchableText(for event: Event) -> String {
        [
            event.name,
            event.category,
            location(for: event),
            organizer(for: event),
            event.excerpt,
            event.teaser,
            event.description,
            event.attendanceMode.map { MMEventAttendanceMode(rawValue: $0)?.title ?? $0 },
        ]
            .compactMap { $0 }
            .joined(separator: " ")
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
    }
}

private extension DateFormatter {
    nonisolated static func mmEventString(from date: Date, dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate(dateFormat)

        return formatter.string(from: date)
    }
}
