//
//  Container+LegacyEventService.swift
//  moers festival
//
//  Created for Factory migration
//

import Foundation
import FactoryKit
import Core
import MMEvents
import Cache

public extension Container {

    @MainActor
    var legacyEventService: Factory<LegacyEventService> {
        self {
            DefaultLegacyEventService(
                client: Container.shared.httpClient(),
                try! Storage<String, [Event]>(
                    diskConfig: DiskConfig(name: "LegacyEventService"),
                    memoryConfig: MemoryConfig(),
                    fileManager: .default,
                    transformer: TransformerFactory.forCodable(ofType: [Event].self)
                )
            )
        }
    }
    
    @MainActor
    var festivalEventService: Factory<FestivalEventService> {
        self {
            DefaultFestivalEventService(client: Container.shared.httpClient())
        }
    }

}
