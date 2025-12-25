//
//  RubbishPickupItem.swift
//  MMRubbish
//
//  Created by Lennart Fischer on 26.12.19.
//

import Foundation
import ModernNetworking

public struct RubbishPickupItem: Model, Codable, Identifiable, Equatable {
    
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
    
    public static var placeholder: [RubbishPickupItem] = {
        
        let now = Date()
        
        return [
            RubbishPickupItem(date: now, type: .organic),
            RubbishPickupItem(date: now, type: .paper),
            RubbishPickupItem(date: Date(timeIntervalSinceNow: 1 * 24 * 60 * 60), type: .plastic),
            RubbishPickupItem(date: Date(timeIntervalSinceNow: 2 * 24 * 60 * 60), type: .residual)
          ]
    }()
    
    public static var decoder: JSONDecoder {
        
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "Europe/Berlin")
        
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return decoder
        
    }
    
}
