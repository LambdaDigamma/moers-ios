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
import OSLog
import SwiftUI

@MainActor
public class TimetableViewModel: ObservableObject {

    @Published public private(set) var days: [TimetableDay] = []
    @Published public private(set) var selectedDate: Date = Date().stripTimeComponent()
    @Published public private(set) var searchText: String = ""
    @Published public private(set) var isSearchActive: Bool = false
    @Published public private(set) var searchResults: [EventListItemViewModel] = []
    @Published public private(set) var searchSections: [EventListSection] = []
    @Published public private(set) var searchState: TimetableSearchState = .inactive
    @Published var allEventsHideSchedule: Bool = false

    @PersistedFilter(key: "timetableFilter") public var filter: EventFilter {
        didSet {
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

    public var isSearching: Bool {
        isSearchActive
    }

    public var hasSearchQuery: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
    private let searchEvents: @Sendable (String) async throws -> [Event]
    private var storedEvents: [Event] = []
    private var favoriteEventIDs = Set<Int64>()
    private var searchTask: Task<Void, Never>?
    private var searchGeneration = 0
    private var eventListItemViewModelsByID: [Event.ID: EventListItemViewModel] = [:]
    private static let searchDebounceNanoseconds: UInt64 = 200_000_000
    nonisolated private static let searchLogger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "MMEvents",
        category: "TimetableSearch"
    )

    public var cancellables = Set<AnyCancellable>()

    public init(
        repository: EventRepository = Container.shared.eventRepository(),
        searchEvents: @escaping @Sendable (EventRepository, String) async throws -> [Event] = { repository, query in
            try await repository.searchEvents(query: query)
        }
    ) {

        self.repository = repository
        self.searchEvents = { query in
            try await searchEvents(repository, query)
        }

        self.setupObserver()

    }

    deinit {
        searchTask?.cancel()
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
                self.rebuildSearchResultsIfNeeded()

            }
            .store(in: &cancellables)


    }

    public func selectDate(_ date: Date) {
        let resolvedDate = self.resolvedSelectedDate(
            for: self.dates,
            preferredDate: date
        )

        guard selectedDate != resolvedDate else { return }

        self.selectedDate = resolvedDate
    }

    public func updateSearchText(_ text: String) {
        guard isSearchActive else { return }
        guard searchText != text else { return }

        searchText = text
        scheduleSearchResultsUpdate(debounce: true)
    }

    public func retrySearch() {
        guard isSearchActive else { return }

        scheduleSearchResultsUpdate(debounce: false)
    }

    public func beginSearch() {
        searchTask?.cancel()
        searchGeneration += 1
        searchText = ""
        isSearchActive = true
        applyCachedSearchResults()
    }

    public func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
        searchGeneration += 1
        searchText = ""
        setSearchResults([])
        searchState = .inactive
        isSearchActive = false
    }

    public func setSearchActive(_ isActive: Bool) {
        guard isSearchActive != isActive else { return }

        if isActive {
            beginSearch()
        } else {
            cancelSearch()
        }
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
                        makeEventListItemViewModel(for: event)
                    }

                return TimetableDay(date: date, events: events)
            }

        self.selectDate(selectedDate)

    }

    private func rebuildSearchResultsIfNeeded() {

        guard isSearchActive || hasSearchQuery else {
            searchTask?.cancel()
            setSearchResults([])
            searchState = .inactive
            return
        }

        scheduleSearchResultsUpdate(debounce: false)

    }

    private func scheduleSearchResultsUpdate(debounce: Bool) {

        let query = searchText
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        searchTask?.cancel()

        guard isSearchActive else {
            searchState = .inactive
            return
        }

        guard !trimmedQuery.isEmpty else {
            searchGeneration += 1
            applyCachedSearchResults()
            return
        }

        searchGeneration += 1
        let generation = searchGeneration
        let debounceNanoseconds = Self.searchDebounceNanoseconds

        searchState = .loading

        searchTask = Task.detached(priority: .userInitiated) { [weak self, searchEvents] in
            do {
                if debounce {
                    try await Task.sleep(nanoseconds: debounceNanoseconds)
                }

                try Task.checkCancellation()

                let events = try await searchEvents(query)

                try Task.checkCancellation()

                await MainActor.run { [weak self] in
                    guard let self else { return }
                    guard self.isSearchActive, self.searchGeneration == generation else { return }

                    self.setSearchResults(events.map { event in
                        self.makeEventListItemViewModel(for: event)
                    })
                    self.searchState = .loaded
                }
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }

                let message = String(describing: error)
                Self.searchLogger.error("Timetable search failed: \(message, privacy: .public)")

                await MainActor.run { [weak self] in
                    guard let self else { return }
                    guard self.isSearchActive, self.searchGeneration == generation else { return }

                    self.setSearchResults([])
                    self.searchState = .failed
                }
            }
        }

    }

    private func setSearchResults(
        _ results: [EventListItemViewModel]
    ) {
        searchResults = results
        searchSections = EventListSectionBuilder().sections(for: results)
    }

    private func applyCachedSearchResults() {

        searchTask?.cancel()
        searchTask = nil
        searchState = .loaded
        setSearchResults(storedEvents
            .sorted(by: EventSearchOrdering.sortEventsByDateAndTitle)
            .map { event in
                makeEventListItemViewModel(for: event)
            })

    }

    private func makeEventListItemViewModel(for event: Event) -> EventListItemViewModel {

        if let viewModel = eventListItemViewModelsByID[event.id] {
            update(viewModel, with: event)
            return viewModel
        }

        let viewModel = EventListItemViewModel(
            eventID: event.id,
            title: event.name,
            startDate: event.startDate,
            endDate: event.endDate,
            location: event.place?.name,
            media: event.headerMedia,
            isOpenEnd: event.extras?.openEnd ?? false,
            isLiked: favoriteEventIDs.contains(Int64(event.id)),
            scheduleDisplayMode: event.scheduleDisplayMode
        )
        eventListItemViewModelsByID[event.id] = viewModel

        return viewModel

    }

    private func update(
        _ viewModel: EventListItemViewModel,
        with event: Event
    ) {

        if viewModel.title != event.name {
            viewModel.title = event.name
        }

        if viewModel.startDate != event.startDate {
            viewModel.startDate = event.startDate
        }

        if viewModel.endDate != event.endDate {
            viewModel.endDate = event.endDate
        }

        if viewModel.location != event.place?.name {
            viewModel.location = event.place?.name
        }

        if viewModel.media != event.headerMedia {
            viewModel.media = event.headerMedia
        }

        if viewModel.isOpenEnd != (event.extras?.openEnd ?? false) {
            viewModel.isOpenEnd = event.extras?.openEnd ?? false
        }

        let isLiked = favoriteEventIDs.contains(Int64(event.id))
        if viewModel.isLiked != isLiked {
            viewModel.isLiked = isLiked
        }

        if viewModel.scheduleDisplayMode != event.scheduleDisplayMode {
            viewModel.scheduleDisplayMode = event.scheduleDisplayMode
        }

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

        if let today = dates.first(where: { $0.isToday }) {
            return today
        }

        return dates.first ?? preferredDate.stripTimeComponent()
    }

}
