#if !os(tvOS)
//
//  MMEventsFrameworkConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 06.01.21.
//  Copyright © 2021 CodeForNiederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import ModernNetworking
import Cache
import Core
@preconcurrency import MMEvents
@preconcurrency import FactoryKit

class MMEventsFrameworkConfiguration: BootstrappingProcedureStep {
    
    func execute(with application: UIApplication) {
        
        let database = Container.shared.appDatabase.resolve()
        
        self.setupPlaces()
        self.setupEvents()
        
        let dbWriter = database.dbWriter
        let dbReader = database.reader
        Container.shared.favoriteEventsStore.scope(.singleton).register {
            FavoriteEventsStore(writer: dbWriter, reader: dbReader)
        }
        Container.shared.widgetFavoritesSyncBridge().start()
        
    }
    
    private func setupPlaces() {
        
        Container.shared.placeRepository.scope(.cached).register {
            let database = Container.shared.appDatabase.resolve()
            
            return PlaceRepository(
                store: PlaceStore(writer: database.dbWriter, reader: database.reader),
                service: DefaultPlaceService(client: Container.shared.httpClient())
            )
        }
        
    }
    
    private func setupEvents() {
        
        EventPackageConfiguration.eventActiveMinuteThreshold = .init(value: 30, unit: .minutes)
//        let service = StaticEventService(events: .success([
//            .stub(withID: 1).setting(\.startDate, to: Date()),
//            .stub(withID: 2).setting(\.startDate, to: Date().addingTimeInterval(60 * 60 * 24)),
//            .stub(withID: 3).setting(\.startDate, to: Date().addingTimeInterval(60 * 60 * 24 * 2)),
//        ]))
        
        Container.shared.legacyEventService.register {
            let cache = ApplicationController.eventCache()
            let client = Container.shared.httpClient()
            return DefaultLegacyEventService(client: client, cache) as LegacyEventService
        }
        
        Container.shared.eventRepository.scope(.cached).register {
            let database = Container.shared.appDatabase.resolve()
            let client = Container.shared.httpClient()
            
            return EventRepository(
                store: EventStore(writer: database.dbWriter, reader: database.reader),
                service: DefaultEventService(client: client),
                placeStore: Container.shared.placeRepository().store,
                pageStore: Container.shared.pageRepository().store
            )
        }
        
    }
    
//    private func eventService() -> EventService {
//
//        if LaunchArguments().useMockedData() {
//
//        } else {
//
//            let service = DefaultEventService(loader)
//
//            return service
//
//        }
//
//    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

#endif
