//
//  MMEventFilter.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation
import MMEvents

nonisolated struct MMEventFilter: Equatable, Hashable {
    var dateScope: MMEventDateScope = .all
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

    var tokenTitles: [String] {
        var titles: [String] = []

        if let dateTitle = dateScope.tokenTitle {
            titles.append(dateTitle)
        }

        if onlyFavorites {
            titles.append(String(localized: "Favorites"))
        }

        if onlyWithImages {
            titles.append(String(localized: "With Images"))
        }

        if onlyFree {
            titles.append(String(localized: "Free"))
        }

        titles.append(contentsOf: categories.sorted())
        titles.append(contentsOf: venues.sorted())
        titles.append(contentsOf: organizers.sorted())
        titles.append(contentsOf: attendanceModes.compactMap { MMEventAttendanceMode(rawValue: $0)?.title ?? $0 }.sorted())

        return titles
    }

    func matches(_ event: Event, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        if !matchesDateScope(event, calendar: calendar) {
            return false
        }

        if !categories.isEmpty, !categories.contains(event.category ?? "") {
            return false
        }

        if !venues.isEmpty, !venues.contains(MMEventFormatter.location(for: event) ?? "") {
            return false
        }

        if !organizers.isEmpty, !organizers.contains(MMEventFormatter.organizer(for: event) ?? "") {
            return false
        }

        if !attendanceModes.isEmpty, !attendanceModes.contains(event.attendanceMode ?? "") {
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

    private func matchesDateScope(_ event: Event, calendar: Calendar) -> Bool {
        guard dateScope != .all else { return true }
        guard let startDate = event.startDate else { return false }

        switch dateScope {
        case .all:
            return true
        case .today:
            return MMEventFormatter.overlapsDay(event, dayOffset: 0, calendar: calendar)
        case .tomorrow:
            return MMEventFormatter.overlapsDay(event, dayOffset: 1, calendar: calendar)
        case .nextSevenDays:
            guard let end = calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: Date())) else { return false }
            return startDate < end
        case .weekend:
            return MMEventFormatter.isWeekendEvent(event, calendar: calendar)
        }
    }
}
