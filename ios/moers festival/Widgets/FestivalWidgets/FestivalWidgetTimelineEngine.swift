//
//  FestivalWidgetTimelineEngine.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

enum FestivalWidgetTimelineEngine {

    static let liveWithoutEndThreshold: TimeInterval = 30 * 60
    static let longEventThreshold: TimeInterval = 90 * 60
    static let longEventGracePeriod: TimeInterval = 15 * 60
    static let minimumRefreshInterval: TimeInterval = 5 * 60
    static let maximumRefreshInterval: TimeInterval = 30 * 60

    static func buildContent(
        from events: [FestivalWidgetEvent],
        now: Date = .now
    ) -> FestivalWidgetContent {
        let liveEvents = events
            .compactMap { event -> FestivalWidgetDisplayEvent? in
                state(for: event, now: now) == .live ? FestivalWidgetDisplayEvent(event: event, status: .live) : nil
            }
            .sorted { lhs, rhs in
                lhs.event.startDate ?? .distantFuture < rhs.event.startDate ?? .distantFuture
            }

        let upcomingEvents = events
            .compactMap { event -> FestivalWidgetDisplayEvent? in
                state(for: event, now: now) == .upcoming ? FestivalWidgetDisplayEvent(event: event, status: .upcoming) : nil
            }
            .sorted { lhs, rhs in
                lhs.event.startDate ?? .distantFuture < rhs.event.startDate ?? .distantFuture
            }

        return FestivalWidgetContent(
            liveEvents: liveEvents,
            upcomingEvents: upcomingEvents,
            nextRefreshDate: nextRefreshDate(from: events, now: now)
        )
    }

    private static func state(
        for event: FestivalWidgetEvent,
        now: Date
    ) -> FestivalWidgetStatus? {
        guard let startDate = event.startDate else {
            return nil
        }

        if startDate > now {
            return .upcoming
        }

        let resolvedEndDate = resolvedEndDate(for: event)

        guard let resolvedEndDate, now <= resolvedEndDate else {
            return nil
        }

        if let explicitEndDate = explicitEndDate(for: event) {
            let duration = explicitEndDate.timeIntervalSince(startDate)

            if duration > longEventThreshold && now.timeIntervalSince(startDate) >= longEventGracePeriod {
                return nil
            }

            let firstHalfEnd = startDate.addingTimeInterval(duration / 2)
            guard now <= firstHalfEnd else {
                return nil
            }
        }

        return .live
    }

    private static func resolvedEndDate(for event: FestivalWidgetEvent) -> Date? {
        guard let startDate = event.startDate else {
            return nil
        }

        if let explicitEndDate = explicitEndDate(for: event) {
            return explicitEndDate
        }

        return startDate.addingTimeInterval(liveWithoutEndThreshold)
    }

    private static func explicitEndDate(for event: FestivalWidgetEvent) -> Date? {
        guard let startDate = event.startDate, let endDate = event.endDate, endDate > startDate else {
            return nil
        }

        return endDate
    }

    private static func nextRefreshDate(
        from events: [FestivalWidgetEvent],
        now: Date
    ) -> Date {
        var boundaries: [Date] = []

        for event in events {
            guard let startDate = event.startDate else {
                continue
            }

            if startDate > now {
                boundaries.append(startDate)
            }

            if startDate <= now {
                if let explicitEndDate = explicitEndDate(for: event) {
                    let duration = explicitEndDate.timeIntervalSince(startDate)
                    boundaries.append(explicitEndDate)
                    boundaries.append(startDate.addingTimeInterval(duration / 2))

                    if duration > longEventThreshold {
                        boundaries.append(startDate.addingTimeInterval(longEventGracePeriod))
                    }
                } else {
                    boundaries.append(startDate.addingTimeInterval(liveWithoutEndThreshold))
                }
            }
        }

        let nextRelevantBoundary = boundaries
            .filter { $0 > now.addingTimeInterval(60) }
            .min()

        let earliestAllowed = now.addingTimeInterval(minimumRefreshInterval)
        let latestAllowed = now.addingTimeInterval(maximumRefreshInterval)

        guard let nextRelevantBoundary else {
            return latestAllowed
        }

        return min(max(nextRelevantBoundary, earliestAllowed), latestAllowed)
    }

}