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
    @Published public private(set) var selectedDate: Date = Date().stripTimeComponent()
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
    
    @LazyInjected(\.favoriteEventsStore) private var favoriteEventsStore
    
    private let repository: EventRepository
    private var storedEvents: [Event] = []
    private var favoriteEventIDs = Set<Int64>()
    
    public var cancellables = Set<AnyCancellable>()
    
    public init() {
        
        self.repository = Container.shared.eventRepository()
        
        self.setupObserver()
        
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
                            scheduleDisplayMode: event.scheduleDisplayMode
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
        
        if let today = dates.first(where: { $0.isToday }) {
            return today
        }
        
        return dates.first ?? preferredDate.stripTimeComponent()
    }
    
}
