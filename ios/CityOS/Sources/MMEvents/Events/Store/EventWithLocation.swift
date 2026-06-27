//
//  EventWithLocation.swift
//  
//
//  Created by Lennart Fischer on 24.04.23.
//

import Foundation
import GRDB

nonisolated public struct EventWithPlace: FetchableRecord, Decodable, Equatable, Sendable {
    
    public let event: EventRecord
    public let place: PlaceRecord?
    
}

nonisolated public struct EventWithRelations: FetchableRecord, Decodable, Equatable, Sendable {
    
    public let event: EventRecord
    public let place: PlaceRecord?
    public let favoriteEvent: FavoriteEventRecord?
    
}
