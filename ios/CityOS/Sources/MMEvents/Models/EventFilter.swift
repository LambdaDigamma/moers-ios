//
//  EventFilter.swift
//  
//
//  Created by Gemini CLI on 15.03.26.
//

import Foundation

public struct EventFilter: Equatable, Hashable {
    
    public var venueIDs: Set<Place.ID> = []
    
    public init(venueIDs: Set<Place.ID> = []) {
        self.venueIDs = venueIDs
    }
    
    public var isEmpty: Bool {
        return venueIDs.isEmpty
    }
    
}
