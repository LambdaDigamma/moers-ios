//
//  Container+LegacyEventService.swift
//  moers festival
//
//  Created for Factory migration
//

import Foundation
import Factory
import MMEvents
import Cache

public extension Container {

    var legacyEventService: Factory<LegacyEventService> {
        self {
            DefaultLegacyEventService(
                Container.shared.httpLoader(),
                try! Storage<String, [Event]>(
                    diskConfig: DiskConfig(name: "LegacyEventService"),
                    memoryConfig: MemoryConfig(),
                    transformer: TransformerFactory.forCodable(ofType: [Event].self)
                )
            )
        }
    }
    
    var festivalEventService: Factory<FestivalEventService> {
        self {
            DefaultFestivalEventService(loader: Container.shared.httpLoader())
        }
    }

}
