//
//  Container+Services.swift
//  Moers
//
//  Created for Factory migration
//

import Foundation
import Factory
import ModernNetworking
import Core

#if canImport(RubbishFeature)
import RubbishFeature
#endif

#if canImport(FuelFeature)
import FuelFeature
#endif

#if canImport(ParkingFeature)
import ParkingFeature
#endif

#if canImport(NewsFeature)
import NewsFeature
#endif

#if canImport(MMEvents)
import MMEvents
#endif

public extension Container {
    
    // MARK: - Rubbish Service
    
#if canImport(RubbishFeature)
    var rubbishService: Factory<RubbishService?> {
        self {
            nil // Will be configured at runtime
        }
    }
#endif
    
    // MARK: - Petrol/Fuel Service
    
#if canImport(FuelFeature)
    var petrolService: Factory<PetrolService?> {
        self {
            nil // Will be configured at runtime
        }
    }
#endif
    
    // MARK: - Parking Service
    
#if canImport(ParkingFeature)
    var parkingService: Factory<ParkingService?> {
        self {
            nil // Will be configured at runtime
        }
    }
#endif
    
    // MARK: - News Service
    
#if canImport(NewsFeature)
    var newsService: Factory<NewsService?> {
        self {
            nil // Will be configured at runtime
        }
    }
#endif
    
    // MARK: - Event Service
    
#if canImport(MMEvents)
    var eventService: Factory<EventService?> {
        self {
            nil // Will be configured at runtime
        }
    }
#endif
    
}
