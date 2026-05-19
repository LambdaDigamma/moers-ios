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
    public var scheduleDisplayMode: EventScheduleDisplayMode
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
    private let currentDateProvider: CurrentDateProviding

    public init(
        eventID: Event.ID?,
        currentDateProvider: CurrentDateProviding = Container.shared.currentDateProvider()
    ) {
        self.eventID = eventID
        self.currentDateProvider = currentDateProvider
        self.repository = Container.shared.eventRepository()
        super.init()
        self.setupListener()
        self.setupCurrentDateListener()
    }

    public func load() {

        guard let eventID = eventID else {
            return
        }

        Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await self.festivalEventService.show(eventID: eventID, cacheMode: .cached)

                await MainActor.run {
                    self.page = response.page
                    self.pageID = response.page?.id
                    self.event = response.event
                    self.eventID = response.event?.id
                    self.header = response.event?.headerMedia
                    self.location = response.place

                    if let event = response.event {
                        self.updateScreenData(for: event)
                    }
                }
            } catch {
                self.logger.error("\(error.localizedDescription)")
                print(error)
            }
        }

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
                self.header = event?.headerMedia
                self.location = event?.place

                if let event {
                    self.updateScreenData(for: event)
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

    private func setupCurrentDateListener() {
        currentDateProvider
            .dateDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, let event = self.event else { return }
                self.updateScreenData(for: event)
            }
            .store(in: &cancellables)
    }

    private func updateScreenData(for event: Event) {
        self.screenData = .init(
            startDate: event.startDate,
            endDate: event.endDate,
            scheduleDisplayMode: event.scheduleDisplayMode,
            timeMode: EventUtilities.timeDisplayMode(
                startDate: event.startDate,
                endDate: event.endDate,
                scheduleDisplayMode: event.scheduleDisplayMode,
                now: currentDateProvider.now
            )
        )
    }

}
