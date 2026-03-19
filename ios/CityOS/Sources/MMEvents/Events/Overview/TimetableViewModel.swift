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
    
    @Published public var dates: [Date] = []
    @Published var selectedDate: Date = .init()
    @Published var daysViewModels: [DayEventsViewModel] = []
    @Published var allEventsHideSchedule: Bool = false
    
    @PersistedFilter(key: "timetableFilter") public var filter: EventFilter {
        didSet {
            self.objectWillChange.send()
            self.updateDaysViewModels()
        }
    }
    
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
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                
                
                
            } receiveValue: { (events: [Event]) in
                
                self.allEventsHideSchedule = !events.isEmpty && events.allSatisfy { event in
                    !event.showsDateComponent
                }
                
                self.dates = DateUtils.sortedUniqueDates(events.compactMap { $0.startDate })
                self.selectedDate = self.resolvedSelectedDate(for: self.dates)
                
                self.updateDaysViewModels()
                
            }
            .store(in: &cancellables)

        
    }
    
    private func updateDaysViewModels() {
        self.daysViewModels = self.dates.map { DayEventsViewModel(date: $0, filter: self.filter) }
    }
    
    public func load() async {
        do {
            try await repository.reloadEvents()
            print("RELOADING")
        } catch {
            print("Failed to reload events: \(error)")
        }
    }

    private func resolvedSelectedDate(for dates: [Date]) -> Date {
        
        if dates.contains(selectedDate) {
            return selectedDate
        }
        
        if let today = dates.first(where: { $0.isToday }) {
            return today
        }
        
        return dates.first ?? Date()
    }
    
}
