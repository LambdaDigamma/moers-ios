//
//  PreviewListEventsView.swift
//
//
//  Created by Lennart Fischer on 07.03.24.
//

import Core
import SwiftUI
import Factory
import OSLog
import Combine

class PreviewListEventsViewModel: StandardViewModel {
    
    @Published var events: [EventListItemViewModel] = []
    
    private let repository: EventRepository
    private let logger = Logger(.coreUi)
    
    public override init() {
        self.repository = Container.shared.eventRepository()
        super.init()
        self.setupObserver()
    }
    
    public func setupObserver() {
        
        cancellables.forEach { $0.cancel() }
        
        repository.events()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { (completion: Subscribers.Completion<Error>) in
                
                self.logger.error("\(completion.debugDescription)")
                
            } receiveValue: { (events: [Event]) in
                
                self.events = events
                    .filter {
                        let createdAt = $0.createdAt ?? Date()
                        return createdAt.formatted(.dateTime.year()) == Date().formatted(.dateTime.year())
                    }
                    .map {
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
    
    public func refresh() {
        
        self.setupObserver()
        
        Task {
            do {
                try await repository.refreshEvents()
            } catch {
                self.logger.error("\(error.debugDescription)")
            }
        }
        
    }
    
}

struct PreviewListEventsView: View {
    
    @StateObject var viewModel = PreviewListEventsViewModel()
    @EnvironmentObject var transmitter: TimetableTransmitter
    
    public init() {
    }
    
    public var body: some View {
        
        ZStack {
            
            List {
                
                ForEach(viewModel.events) { event in
                    Button(action: {
                        if let eventID = event.eventID {
                            transmitter.dispatchShowEvent(eventID)
                        }
                    }) {
                        EventListItem(viewModel: event)
                    }
                    .accessibilityIdentifier("Event-Row-\(event.eventID ?? 0)")
                }
                
            }
            .listStyle(.plain)
            
        }
        .task {
            await viewModel.reload()
        }
        
    }
    
}
