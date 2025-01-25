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

public class DayEventsViewModel: ObservableObject, Identifiable {
    
    internal let date: Date
    internal let startDate: Date
    internal let endDate: Date
    
    @Published var events: [EventListItemViewModel] = []
    
    private let repository: EventRepository
    private let logger = Logger(.coreUi)
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(date: Date) {
        self.date = date
        self.repository = Container.shared.eventRepository()
        
        let range = DateUtils.calculateDateRange(for: date, offset: EventUtilities.defaultDayOffset)
        self.startDate = range.startDate
        self.endDate = range.endDate
        
        self.setupObserver()
        
    }
    
    public func setupObserver() {
        
        cancellables.forEach { $0.cancel() }
        
        repository.events(between: startDate, and: endDate)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { (completion: Subscribers.Completion<Error>) in
                
                self.logger.error("\(completion.debugDescription)")
                
            } receiveValue: { (events: [Event]) in
                
                self.events = events.map {
                    return EventListItemViewModel(
                        eventID: $0.id,
                        title: $0.name,
                        startDate: $0.startDate,
                        endDate: $0.endDate,
                        location: $0.place?.name,
                        media: $0.mediaCollections.getFirstMedia(for: "header"),
                        isOpenEnd: $0.extras?.openEnd ?? false,
                        isPreview: $0.isPreview
                    )
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
        return self.date.formatted(date: .numeric, time: .omitted)
    }
    
}
