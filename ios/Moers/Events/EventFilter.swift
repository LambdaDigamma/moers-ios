//
//  EventFilter.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation
import Events

nonisolated struct EventFilter: Equatable, Hashable {
    var dateScope: EventDateScope = .all
    var categories: Set<String> = []
    var venues: Set<String> = []
    var organizers: Set<String> = []
    var attendanceModes: Set<String> = []
    var onlyFree: Bool = false
    var onlyFavorites: Bool = false
    var onlyWithImages: Bool = false

    var isEmpty: Bool {
        dateScope == .all
        && categories.isEmpty
        && venues.isEmpty
        && organizers.isEmpty
        && attendanceModes.isEmpty
        && !onlyFree
        && !onlyFavorites
        && !onlyWithImages
    }

    var activeFilterCount: Int {
        var count = categories.count + venues.count + organizers.count + attendanceModes.count
        count += dateScope == .all ? 0 : 1
        count += onlyFree ? 1 : 0
        count += onlyFavorites ? 1 : 0
        count += onlyWithImages ? 1 : 0
        return count
    }

    func matches(_ event: Event, calendar: Calendar = .autoupdatingCurrent, now: Date = Date()) -> Bool {
        if !matchesDateScope(event, calendar: calendar, now: now) {
            return false
        }

        if !categories.isEmpty, !categories.contains(event.category ?? "") {
            return false
        }

        if !venues.isEmpty, !venues.contains(EventFormatter.location(for: event) ?? "") {
            return false
        }

        if !organizers.isEmpty, !organizers.contains(EventFormatter.organizer(for: event) ?? "") {
            return false
        }

        if !attendanceModes.isEmpty, !attendanceModes.contains(event.resolvedAttendanceMode ?? "") {
            return false
        }

        if onlyFree, event.extras?.isFree != true {
            return false
        }

        if onlyFavorites, !EventDetailsViewModel.isLiked(id: event.id) {
            return false
        }

        if onlyWithImages, event.image == nil {
            return false
        }

        return true
    }

    private func matchesDateScope(_ event: Event, calendar: Calendar, now: Date) -> Bool {
        guard dateScope != .all else { return true }
        guard let startDate = event.startDate else { return false }

        switch dateScope {
        case .all:
            return true
        case .today:
            return EventFormatter.overlapsDay(event, dayOffset: 0, calendar: calendar, now: now)
        case .tomorrow:
            return EventFormatter.overlapsDay(event, dayOffset: 1, calendar: calendar, now: now)
        case .nextSevenDays:
            guard let end = calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: now)) else { return false }
            return startDate < end
        case .weekend:
            return EventFormatter.isWeekendEvent(event, calendar: calendar)
        }
    }
}
