//
//  EventListSectionBuilder.swift
//
//
//  Created by Codex on 20.05.26.
//

import Foundation

@MainActor
public struct EventListSectionBuilder {

    private let calendar: Calendar
    private let dayOffset: TimeInterval

    public init(
        calendar: Calendar = .autoupdatingCurrent,
        dayOffset: TimeInterval = EventUtilities.defaultDayOffset
    ) {
        self.calendar = calendar
        self.dayOffset = dayOffset
    }

    public func sections(
        for events: [EventListItemViewModel]
    ) -> [EventListSection] {

        var datedEvents: [Date: [EventListItemViewModel]] = [:]
        var undatedEvents: [EventListItemViewModel] = []

        for event in events {
            guard let startDate = event.startDate else {
                undatedEvents.append(event)
                continue
            }

            let effectiveDay = effectiveDay(for: startDate)
            datedEvents[effectiveDay, default: []].append(event)
        }

        var sections = datedEvents.keys
            .sorted()
            .map { effectiveDay in
                EventListSection(
                    id: "day-\(effectiveDay.timeIntervalSince1970)",
                    title: title(for: effectiveDay),
                    effectiveDay: effectiveDay,
                    events: datedEvents[effectiveDay] ?? []
                )
            }

        if !undatedEvents.isEmpty {
            sections.append(
                EventListSection(
                    id: "unscheduled",
                    title: EventPackageStrings.notYetScheduled,
                    effectiveDay: nil,
                    events: undatedEvents
                )
            )
        }

        return sections

    }

    public func effectiveDay(for startDate: Date) -> Date {
        calendar.startOfDay(for: startDate.addingTimeInterval(-dayOffset))
    }

    private func title(for effectiveDay: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateStyle = .full
        formatter.timeStyle = .none

        return formatter.string(from: effectiveDay)
    }

}
