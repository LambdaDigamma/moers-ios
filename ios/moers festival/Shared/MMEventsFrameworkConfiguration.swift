//
//  MMEventsFrameworkConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 06.01.21.
//  Copyright © 2021 CodeForNiederrhein. All rights reserved.
//

import UIKit
import Resolver
import AppScaffold
import ModernNetworking
import Cache
import MMEvents
import Factory

class MMEventsFrameworkConfiguration: BootstrappingProcedureStep {
    
    func execute(with application: UIApplication) {
        
        let loader: HTTPLoader = Resolver.resolve()
        let database = Container.shared.appDatabase.resolve()
        
        let placeStore = self.setupPlaces(loader: loader)
        self.setupEvents(loader: loader, placeStore: placeStore)
        
        Container.shared.favoriteEventsStore.scope(.singleton).register {
            FavoriteEventsStore(writer: database.dbWriter, reader: database.reader)
        }
        
    }
    
    private func setupPlaces(loader: HTTPLoader) -> PlaceStore {
        
        let store = PlaceStore(
            writer: Container.shared.appDatabase.resolve().dbWriter,
            reader: Container.shared.appDatabase.resolve().reader
        )
        
        let service = DefaultPlaceService(loader: loader)
        
        Container.shared.placeRepository.scope(.cached).register {
            PlaceRepository(
                store: store,
                service: service
            )
        }
        
        return store
        
    }
    
    private func setupEvents(loader: HTTPLoader, placeStore: PlaceStore) {
        
        EventPackageConfiguration.eventActiveMinuteThreshold = .init(value: 30, unit: .minutes)
        
        let cache = ApplicationController.eventCache()
        let legacyService = DefaultLegacyEventService(loader, cache)
        
        let service = DefaultEventService(loader)
//        let service = StaticEventService(events: .success([
//            .stub(withID: 1).setting(\.startDate, to: Date()),
//            .stub(withID: 2).setting(\.startDate, to: Date().addingTimeInterval(60 * 60 * 24)),
//            .stub(withID: 3).setting(\.startDate, to: Date().addingTimeInterval(60 * 60 * 24 * 2)),
//        ]))
        
        let store = EventStore(
            writer: Container.shared.appDatabase.resolve().dbWriter,
            reader: Container.shared.appDatabase.resolve().reader
        )
        
        Resolver.register { legacyService as LegacyEventService }
        
        Container.shared.eventRepository.scope(.cached).register {
            EventRepository(
                store: store,
                service: service,
                placeStore: placeStore,
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
    
}
