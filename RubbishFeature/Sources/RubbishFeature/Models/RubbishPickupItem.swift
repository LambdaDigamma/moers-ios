//
//  RubbishPickupItem.swift
//  MMRubbish
//
//  Created by Lennart Fischer on 26.12.19.
//

import Foundation
import ModernNetworking

public struct RubbishPickupItem: Model, Codable, Identifiable {
    
    public let id: UUID = UUID()
    
    public var date: Date
    public var type: RubbishWasteType
    
    public init(date: Date, type: RubbishWasteType) {
        self.date = date
        self.type = type
    }
    
    enum CodingKeys: String, CodingKey {
        case date
        case type
    }
    
}
