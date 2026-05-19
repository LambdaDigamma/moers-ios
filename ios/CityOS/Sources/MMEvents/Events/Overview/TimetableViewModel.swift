//
//  TimetableViewModel.swift
//
//
//  Created by Lennart Fischer on 11.04.23.
//

import Foundation
import Factory
import Combine
import Core
import SwiftUI

@MainActor
public class TimetableViewModel: ObservableObject {

    @Published public private(set) var days: [TimetableDay] = []
    @Published public private(set) var selectedDate: Date
    @Published public private(set) var displayDate: Date
    @Published var allEventsHideSchedule: Bool = false

    @PersistedFilter(key: "timetableFilter") public var filter: EventFilter {
        didSet {
            guard oldValue != filter else { return }
            self.objectWillChange.send()
            self.rebuildDays()
        }
    }

    public var dates: [Date] {
        days.map(\.date)
    }

    public var events: [EventListItemViewModel] {
        days.flatMap(\.events)
    }

    /// Unique venue names for the selected day, ordered by first event appearance.
    public var venues: [String] {
        let dayEvents = eventsForSelectedDay()
        var seen = Set<String>()
        var result: [String] = []
        for event in dayEvents {
            if let location = event.location, !seen.contains(location) {
                seen.insert(location)
                result.append(location)
            }
        }
        return result
    }

    public func eventsForSelectedDay() -> [EventListItemViewModel] {
        days.first(where: {
            Calendar.autoupdatingCurrent.isDate($0.date, inSameDayAs: selectedDate)
        })?.events ?? []
    }

    @LazyInjected(\.favoriteEventsStore) private var favoriteEventsStore

    private let repository: EventRepository
    private let currentDateProvider: CurrentDateProviding
    private var storedEvents: [Event] = []
    private var favoriteEventIDs = Set<Int64>()
    private var isFollowingCurrentDate = true

    public var cancellables = Set<AnyCancellable>()

    public init(
        currentDateProvider: CurrentDateProviding = Container.shared.currentDateProvider()
    ) {

        self.currentDateProvider = currentDateProvider
        self.selectedDate = currentDateProvider.now.stripTimeComponent()
        self.displayDate = currentDateProvider.now
        self.repository = Container.shared.eventRepository()

        self.setupObserver()
        self.setupCurrentDateObserver()

    }

    public func setupObserver() {

        Publishers.CombineLatest(
            repository.events().replaceError(with: []),
            favoriteEventsPublisher()
        )
            .receive(on: DispatchQueue.main)
            .sink { combinedValue in
                let (events, favoriteEventIDs) = combinedValue

                self.storedEvents = events
                self.favoriteEventIDs = favoriteEventIDs
                self.rebuildDays()

            }
            .store(in: &cancellables)


    }

    public func selectDate(_ date: Date) {
        let resolvedDate = self.resolvedSelectedDate(
            for: self.dates,
            preferredDate: date
        )
        self.isFollowingCurrentDate = Calendar.autoupdatingCurrent.isDate(
            resolvedDate,
            inSameDayAs: currentDateProvider.now
        )

        guard selectedDate != resolvedDate else { return }

        self.selectedDate = resolvedDate
    }

    public func load() async {
        do {
            try await repository.reloadEvents()
            print("RELOADING")
        } catch {
            print("Failed to reload events: \(error)")
        }
    }

    public func refresh() async {
        do {
            try await repository.refreshEvents()
        } catch {
            print("Failed to refresh events: \(error)")
        }
    }

    private func favoriteEventsPublisher() -> AnyPublisher<Set<Int64>, Never> {

        if let favoriteEventsStore {
            return favoriteEventsStore.observeFavoriteEvents()
                .map { favoriteInfos in
                    Set(favoriteInfos.compactMap { $0.event.id })
                }
                .replaceError(with: Set<Int64>())
                .eraseToAnyPublisher()
        } else {
            return Just(Set<Int64>())
                .eraseToAnyPublisher()
        }

    }

    private func setupCurrentDateObserver() {
        currentDateProvider
            .dateDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] now in
                guard let self else { return }
                self.refreshDisplayDateIfNeeded(now)
                self.refreshSelectedDateIfNeeded(now)
            }
            .store(in: &cancellables)
    }

    private func refreshDisplayDateIfNeeded(_ now: Date) {
        guard !Calendar.autoupdatingCurrent.isDate(
            displayDate,
            equalTo: now,
            toGranularity: .minute
        ) else {
            return
        }

        displayDate = now
    }

    private func refreshSelectedDateIfNeeded(_ now: Date) {
        guard isFollowingCurrentDate else { return }

        let currentDay = now.stripTimeComponent()
        guard !Calendar.autoupdatingCurrent.isDate(
            selectedDate,
            inSameDayAs: currentDay
        ) else {
            return
        }

        let resolvedDate = resolvedSelectedDate(
            for: dates,
            preferredDate: currentDay
        )
        guard selectedDate != resolvedDate else { return }

        selectedDate = resolvedDate
    }

    private func rebuildDays() {

        let visibleEvents = storedEvents.filter { event in
            matchesFilter(for: event, favoriteEventIDs: favoriteEventIDs)
        }

        self.allEventsHideSchedule = !visibleEvents.isEmpty && visibleEvents.allSatisfy { event in
            !event.showsDateComponent
        }

        self.days = DateUtils.sortedUniqueDates(storedEvents.compactMap { $0.startDate })
            .map { date in
                let range = DateUtils.calculateDateRange(
                    for: date,
                    offset: EventUtilities.defaultDayOffset
                )

                let events = visibleEvents
                    .filter { event in
                        guard let startDate = event.startDate else {
                            return false
                        }

                        guard (range.startDate...range.endDate).contains(startDate) else {
                            return false
                        }

                        return true
                    }
                    .map { event in
                        EventListItemViewModel(
                            eventID: event.id,
                            title: event.name,
                            startDate: event.startDate,
                            endDate: event.endDate,
                            location: event.place?.name,
                            media: event.headerMedia,
                            isOpenEnd: event.extras?.openEnd ?? false,
                            isLiked: favoriteEventIDs.contains(Int64(event.id)),
                            scheduleDisplayMode: event.scheduleDisplayMode,
                            currentDateProvider: currentDateProvider
                        )
                    }

                return TimetableDay(date: date, events: events)
            }

        self.selectDate(selectedDate)

    }

    private func matchesFilter(
        for event: Event,
        favoriteEventIDs: Set<Int64>
    ) -> Bool {

        if !filter.venueIDs.isEmpty {
            guard let placeID = event.place?.id, filter.venueIDs.contains(placeID) else {
                return false
            }
        }

        if filter.showOnlyFavorites {
            guard favoriteEventIDs.contains(Int64(event.id)) else {
                return false
            }
        }

        return true

    }

    private func resolvedSelectedDate(
        for dates: [Date],
        preferredDate: Date
    ) -> Date {

        if let matchingDate = dates.first(where: {
            Calendar.autoupdatingCurrent.isDate($0, inSameDayAs: preferredDate)
        }) {
            return matchingDate
        }

        let currentDate = currentDateProvider.now
        if let today = dates.first(where: {
            Calendar.autoupdatingCurrent.isDate($0, inSameDayAs: currentDate)
        }) {
            return today
        }

        return dates.first ?? preferredDate.stripTimeComponent()
    }

}
