//
//  EventWithLocation.swift
//  
//
//  Created by Lennart Fischer on 24.04.23.
//

import Foundation
import GRDB

public struct EventWithPlace: FetchableRecord, Decodable, Equatable {
    
    public let event: EventRecord
    public let place: PlaceRecord?
    
}

public struct EventWithRelations: FetchableRecord, Decodable, Equatable {
    
    public let event: EventRecord
    public let place: PlaceRecord?
    public let favoriteEvent: FavoriteEventRecord?
    
}
