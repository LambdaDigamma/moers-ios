//
//  RubbishSection.swift
//  
//
//  Created by Lennart Fischer on 02.02.22.
//

import Foundation

public struct RubbishSection: Hashable, Equatable {
    
    public let header: String
    public let items: [RubbishPickupItem]
    
    public init(
        header: String,
        items: [RubbishPickupItem]
    ) {
        self.header = header
        self.items = items
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(header)
    }
    
}
