//
//  CachedPartialLine.swift
//  
//
//  Created by Lennart Fischer on 18.12.22.
//

import Foundation

public typealias StatelessLineIdentifier = String

extension StatelessIdentifier: LineIdentifiable {
    
    public var lineIdentifier: String {
        self
    }
    
}

public struct CachedPartialLine: Codable, Identifiable {
    
    public let id: StatelessLineIdentifier
    
    public let origin: CachedEFAStation
    public let destination: CachedEFAStation
    
    public let plannedDeparture: Date
    public let plannedArrival: Date
    
    public init(
        id: StatelessLineIdentifier,
        origin: CachedEFAStation,
        destination: CachedEFAStation,
        plannedDeparture: Date,
        plannedArrival: Date
    ) {
        self.id = id
        self.origin = origin
        self.destination = destination
        self.plannedDeparture = plannedDeparture
        self.plannedArrival = plannedArrival
    }
    
}
