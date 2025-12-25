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

public class TimetableViewModel: ObservableObject {
    
    @Published public var dates: [Date] = []
    @Published var selectedDate: Date = .init()
    @Published var daysViewModels: [DayEventsViewModel] = []
    @Published var allEventsArePreview: Bool = false
    
    public var events: [EventListItemViewModel] {
        daysViewModels.map { $0.events }.reduce([], +)
    }
    
    private let repository: EventRepository
    
    public var cancellables = Set<AnyCancellable>()
    
    public init() {
        
        self.repository = Container.shared.eventRepository()
        
        self.setupObserver()
        
    }
    
    public func setupObserver() {
        
        repository.events()
            .sink { (completion: Subscribers.Completion<Error>) in
                
                
                
            } receiveValue: { (events: [Event]) in
                
                self.allEventsArePreview = events.allSatisfy { event in
                    event.isPreview
                }
                
                self.dates = DateUtils.sortedUniqueDates(events.compactMap { $0.startDate })
                
                self.daysViewModels = self.dates.map { DayEventsViewModel(date: $0) }
                
                if self.dates.contains(where: { $0.isToday }) {
                    self.selectedDate = self.dates.filter { $0.isToday }.first ?? self.dates.first ?? Date()
                } else {
                    self.selectedDate = self.dates.first ?? Date()
                }
                
            }
            .store(in: &cancellables)

        
    }
    
    public func load() {
        
        Task {
            try await repository.reloadEvents()
            print("RELOADING")
        }
        
    }
    
}
