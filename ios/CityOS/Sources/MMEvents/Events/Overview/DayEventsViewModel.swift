//
//  DayEventsViewModel.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import Foundation
import Factory
import Combine
import OSLog
import Core

@MainActor
public class DayEventsViewModel: ObservableObject, Identifiable {
    
    internal let date: Date
    internal let startDate: Date
    internal let endDate: Date
    internal let filter: EventFilter
    
    @Published var events: [EventListItemViewModel] = []
    
    @LazyInjected(\.favoriteEventsStore) var favoriteEventsStore: FavoriteEventsStore?
    
    private let repository: EventRepository
    private let logger = Logger(.coreUi)
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(date: Date, filter: EventFilter = .init()) {
        self.date = date
        self.filter = filter
        self.repository = Container.shared.eventRepository()
        
        let range = DateUtils.calculateDateRange(for: date, offset: EventUtilities.defaultDayOffset)
        self.startDate = range.startDate
        self.endDate = range.endDate
        
        self.setupObserver()
        
    }
    
    public func setupObserver() {
        
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        let favoriteEventsPublisher = favoriteEventsStore?.observeFavoriteEvents()
            .map { (favoriteInfos: [FavoriteEventInfo]) in
                Set(favoriteInfos.compactMap { $0.event.id })
            }
            .replaceError(with: Set<Int64>())
            .eraseToAnyPublisher() ?? Just(Set<Int64>()).eraseToAnyPublisher()
        
        Publishers.CombineLatest(
            repository.events(between: startDate, and: endDate).replaceError(with: []),
            favoriteEventsPublisher
        )
            .receive(on: DispatchQueue.main)
            .sink { (events, favoriteIDs) in
                MainActor.assumeIsolated {
                self.events = events
                    .filter { event in
                        
                        // Venue Filter
                        if !self.filter.venueIDs.isEmpty {
                            guard let placeID = event.place?.id, self.filter.venueIDs.contains(placeID) else {
                                return false
                            }
                        }
                        
                        // Favorites Filter
                        if self.filter.showOnlyFavorites {
                            guard favoriteIDs.contains(Int64(event.id)) else {
                                return false
                            }
                        }
                        
                        return true
                        
                    }
                    .map { event in
                        return EventListItemViewModel(
                            eventID: event.id,
                            title: event.name,
                            startDate: event.startDate,
                            endDate: event.endDate,
                            location: event.place?.name,
                            media: event.headerMedia,
                            isOpenEnd: event.extras?.openEnd ?? false,
                            isLiked: favoriteIDs.contains(Int64(event.id)),
                            scheduleDisplayMode: event.scheduleDisplayMode
                        )
                    }
                }
            }
            .store(in: &cancellables)
        
        
    }
    
    // MARK: - Actions
    
    public func reload() async {
        
        do {
            try await repository.reloadEvents()
        } catch {
            self.logger.error("\(error.debugDescription)")
        }
        
    }
    
    public func refresh() async {
        
        do {
            try await repository.refreshEvents()
        } catch {
            self.logger.error("\(error.debugDescription)")
        }
        
    }
    
    public var id: String {
        return "\(self.date.formatted(date: .numeric, time: .omitted))-\(self.filter.hashValue)"
    }
    
}
