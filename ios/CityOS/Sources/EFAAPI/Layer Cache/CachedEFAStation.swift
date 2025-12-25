//
//  CachedEFAStation.swift
//  
//
//  Created by Lennart Fischer on 18.12.22.
//

import Foundation
import Core

public struct CachedEFAStation: CacheableStation {
    
    public var id: StatelessStopIdentifier
    
    public var name: String
    
    public var coordinates: Point?
    
    public init(
        id: StatelessStopIdentifier,
        name: String,
        coordinates: Point? = nil
    ) {
        self.id = id
        self.name = name
        self.coordinates = coordinates
    }
    
}
