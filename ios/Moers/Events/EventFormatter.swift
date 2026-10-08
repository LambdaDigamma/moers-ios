//
//  EventFormatter.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation
import Events

nonisolated enum EventFormatter {
    static func location(for event: Event) -> String? {
        EventPresentation.location(for: event)
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
        EventPresentation.dateRange(for: event, calendar: calendar)
    }

    static func dayBadge(for event: Event) -> (day: String, month: String)? {
        guard event.showsDateComponent, let startDate = event.startDate else { return nil }
        return (
            DateFormatter.mmEventString(from: startDate, dateFormat: "dd"),
            DateFormatter.mmEventString(from: startDate, dateFormat: "MMM")
        )
    }

    static func compactDate(for event: Event, calendar: Calendar = .autoupdatingCurrent, now: Date = Date()) -> String? {
        guard event.showsDateComponent, let startDate = event.startDate else { return nil }

        if !event.showsTimeComponent {
            return DateFormatter.mmEventString(from: startDate, dateFormat: "dd.MM.")
        }

        if calendar.isDate(startDate, inSameDayAs: now) {
            return DateFormatter.mmEventString(from: startDate, dateFormat: "HH:mm")
        }

        if calendar.date(byAdding: .day, value: 1, to: now).map { calendar.isDate(startDate, inSameDayAs: $0) } == true {
            let time = DateFormatter.mmEventString(from: startDate, dateFormat: "HH:mm")
            return String(localized: "Tomorrow \(time)")
        }

        return DateFormatter.mmEventString(from: startDate, dateFormat: "dd.MM. HH:mm")
    }

    static func overlapsToday(_ event: Event, calendar: Calendar = .autoupdatingCurrent, now: Date = Date()) -> Bool {
        overlapsDay(event, dayOffset: 0, calendar: calendar, now: now)
    }

    static func overlapsDay(_ event: Event, dayOffset: Int, calendar: Calendar = .autoupdatingCurrent, now: Date = Date()) -> Bool {
        let dayStart = calendar.startOfDay(for: now)
        guard let targetStart = calendar.date(byAdding: .day, value: dayOffset, to: dayStart),
              let targetEnd = calendar.date(byAdding: .day, value: 1, to: targetStart),
              let startDate = event.startDate else { return false }

        let endDate = event.endDate ?? startDate
        return startDate < targetEnd && (endDate > targetStart || startDate >= targetStart)
    }

    static func isNextDaysEvent(_ event: Event, calendar: Calendar = .autoupdatingCurrent, now: Date = Date()) -> Bool {
        let today = calendar.startOfDay(for: now)
        guard let startDate = event.startDate,
              let twoDaysOut = calendar.date(byAdding: .day, value: 2, to: today),
              let sevenDaysOut = calendar.date(byAdding: .day, value: 7, to: today) else { return false }

        return startDate >= twoDaysOut && startDate < sevenDaysOut
    }

    static func isFutureEvent(_ event: Event, calendar: Calendar = .autoupdatingCurrent, now: Date = Date()) -> Bool {
        guard let startDate = event.startDate,
              let sevenDaysOut = calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: now)) else { return false }

        return startDate >= sevenDaysOut
    }

    static func isWeekendEvent(_ event: Event, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        guard let startDate = event.startDate else { return false }
        let weekday = calendar.component(.weekday, from: startDate)
        return weekday == 1 || weekday == 7
    }

    static func searchableText(for event: Event) -> String {
        let values = [
            event.name,
            event.category,
            location(for: event),
            organizer(for: event),
            event.excerpt,
            event.teaser,
            event.description,
            event.attendanceTitle,
        ]
            .compactMap { $0 }
            .joined(separator: " ")
        return EventSearchTextNormalizer().normalize(values)
    }
}

private extension DateFormatter {
    nonisolated static func mmEventString(from date: Date, dateFormat: String) -> String {
        let template = dateFormat.replacingOccurrences(of: "HH", with: "j")
        return EventPresentation.dateString(date, template: template)
    }
}
