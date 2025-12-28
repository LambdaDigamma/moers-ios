//
//  VenueDetailViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 07.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import SwiftUI
import Resolver
import MMEvents
import Factory
import Combine

public class VenueDetailViewModel: StandardViewModel {
    
    private let placeID: Place.ID
    
    @Published var name: String
    @Published var subtitle: String
    
    @Published var addressLine1: String?
    @Published var addressLine2: String?
    
    @Published var point: Point?
    
    @Published var pageID: Page.ID?
    
    @Published var events: [EventListItemViewModel] = [
        Event.stub(withID: 3)
            .setting(\.name, to: "Gamo Singers + tba (ET, DE)")
            .setting(\.startDate, to: Date(timeIntervalSinceNow: -25 * 60))
            .setting(\.endDate, to: Date(timeIntervalSinceNow: 25 * 60))
            .setting(\.place, to: Place.stub(withID: 1)),
        Event
            .stub(withID: 1)
            .setting(\.name, to: "ANNEX 4")
            .setting(\.startDate, to: .init(timeIntervalSinceNow: 60 * 5)),
        Event
            .stub(withID: 2)
            .setting(\.name, to: "Kasper Agnas (SE)")
            .setting(\.startDate, to: .init(timeIntervalSinceNow: 60 * 65)),
        Event.stub(withID: 4),
    ].map { (event: Event) in
        return EventListItemViewModel(
            title: event.name,
            startDate: event.startDate,
            endDate: event.endDate,
            location: event.place?.name,
            isPreview: event.isPreview
        )
    }
    
    private let eventRepository: EventRepository
    
    public init(placeID: Place.ID) {
        self.placeID = placeID
        self.name = ""
        self.subtitle = ""
        self.eventRepository = Container.shared.eventRepository()
        super.init()
        self.setupListener()
    }
    
    public func setupListener() {
        
        eventRepository.store
            .observeEvents(for: self.placeID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                
            } receiveValue: { (events: [EventRecord]) in
                
                self.events = events
                    .map { $0.toBase() }
                    .map({ (event: Event) in
                        return EventListItemViewModel(
                            eventID: event.id,
                            title: event.name,
                            startDate: event.startDate,
                            endDate: event.endDate,
                            location: event.place?.name,
                            media: event.mediaCollections.getFirstMedia(for: "header"),
                            isOpenEnd: event.extras?.openEnd ?? false,
                            isPreview: event.isPreview
                        )
                    })
                
            }
            .store(in: &cancellables)
        
    }
    
}
