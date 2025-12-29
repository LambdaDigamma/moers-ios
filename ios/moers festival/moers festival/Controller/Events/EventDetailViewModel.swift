//
//  EventDetailViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 23.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import OSLog
import Combine
import MMEvents
import MMPages
import MediaLibraryKit
import Foundation
import CoreLocation
import Factory

public struct EventDetailScreenData {
    
    public var startDate: Date?
    public var endDate: Date?
    public var timeMode: TimeDisplayMode
    
}

public class EventDetailViewModel: StandardViewModel {
    
    @LazyInjected(\.legacyEventService) var legacyEventService
    @LazyInjected(\.festivalEventService) var festivalEventService
    
    private let logger: Logger = Logger(.coreAppLifecycle)
    
    @Published public var eventID: Event.ID?
    @Published public var pageID: MMPages.Page.ID?
    @Published var page: MMPages.Page?
    @Published var event: Event?
    @Published var header: Media?
    @Published var location: Place?
    
    @Published var screenData: EventDetailScreenData?
    
    let repository: EventRepository
    
    public init(eventID: Event.ID?) {
        self.eventID = eventID
        self.repository = Container.shared.eventRepository()
        super.init()
        self.setupListener()
    }
    
    public func load() {
        
        guard let eventID = eventID else {
            return
        }

        festivalEventService.show(eventID: eventID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in

                switch completion {
                    case .failure(let error):
                        self.logger.error("\(error.localizedDescription)")
                        print(error)
                    default: break
                }

            } receiveValue: { (response: FestivalEventPageResponse) in

                self.page = response.page
                self.pageID = response.page?.id
                self.event = response.event
                self.eventID = response.event?.id
                self.header = response.event?.mediaCollections.getFirstMedia(for: "header")
                self.location = response.place

                if let event = response.event {
                    self.screenData = .init(
                        startDate: event.startDate,
                        endDate: event.endDate,
                        timeMode: EventUtilities.timeDisplayMode(
                            startDate: event.startDate,
                            endDate: event.endDate,
                            isPreview: event.isPreview
                        )
                    )
                }

            }
            .store(in: &cancellables)
        
    }
    
    public func setupListener() {
        
        guard let eventID else { return }

        self.repository.eventDetail(id: eventID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in

                switch completion {
                    case .failure(let error):
                        self.logger.error("\(error.localizedDescription)")
                        print(error)
                    default: break
                }

            } receiveValue: { (event: Event?) in

                self.pageID = event?.pageID
                self.event = event
                self.header = event?.mediaCollections.getFirstMedia(for: "header")
                self.location = event?.place

                if let event {
                    self.screenData = .init(
                        startDate: event.startDate,
                        endDate: event.endDate,
                        timeMode: EventUtilities.timeDisplayMode(
                            startDate: event.startDate,
                            endDate: event.endDate,
                            isPreview: event.isPreview
                        )
                    )
                }

            }
            .store(in: &cancellables)
        
    }
    
    public func reload() {
        
//        guard let eventID else {
//            self.logger.warning("No event ID found while reloading.")
//            return
//        }
//
//        Task {
//            do {
//                try await self.repository.reloadEvent(for: eventID)
//            } catch {
//                self.logger.error("\(error.debugDescription)")
//            }
//        }
        
    }
    
    public func refresh() {
        
//        guard let eventID else {
//            self.logger.warning("No event ID found while refreshing.")
//            return
//        }
//
//        Task {
//            do {
//                try await self.repository.refreshEvent(for: eventID)
//            } catch {
//                self.logger.error("\(error.debugDescription)")
//            }
//        }
        
    }
    
    public func cancel() {
        
        self.cancellables.forEach { $0.cancel() }
        
    }
    
}
