//
//  DashboardConfig.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

import Foundation

public struct DashboardConfig: Codable {
    
    public var items: [DashboardItemConfigurable] = []
    public var updatedAt: Date?
    
    public init(
        items: [DashboardItemConfigurable] = [],
        updatedAt: Date? = Date()
    ) {
        self.items = items
        self.updatedAt = updatedAt
    }
    
    public static func `default`() -> DashboardConfig {
        return DashboardConfig(
            items: [
                PetrolDashboardConfiguration(),
                RubbishDashboardConfiguration(),
                ParkingDashboardConfiguration(),
            ],
            updatedAt: Date()
        )
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.items = try container.decode([DashboardItemConfigurableWrapper].self, forKey: .items).map { $0.base }
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(items.map { DashboardItemConfigurableWrapper($0) }, forKey: .items)
        try container.encode(updatedAt, forKey: .updatedAt)
        
    }
    
    public enum CodingKeys: String, CodingKey {
        case items = "items"
        case updatedAt = "updated_at"
    }
    
    internal enum DashboardItemType: String, Codable {
        case rubbish = "rubbish"
        case petrol = "petrol"
        case unknown = "unknown"
    }
    
    internal struct DashboardItemConfigurableWrapper: Codable {
        
        internal var itemType: DashboardItemType
        internal var base: DashboardItemConfigurable
        
        internal init(_ base: DashboardItemConfigurable) {
            
            self.base = base
            
            if base is PetrolDashboardConfiguration {
                self.itemType = .petrol
            } else if base is RubbishDashboardConfiguration {
                self.itemType = .rubbish
            } else {
                self.itemType = .unknown
            }
            
        }
        
        internal init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.itemType = try container.decode(DashboardItemType.self, forKey: .itemType)
            
            if itemType == .petrol {
                self.base = try container.decode(PetrolDashboardConfiguration.self, forKey: .base)
            } else if itemType == .rubbish {
                self.base = try container.decode(RubbishDashboardConfiguration.self, forKey: .base)
            } else {
                self.base = try container.decode(EmptyDashboardConfiguration.self, forKey: .base)
            }
            
        }
        
        func encode(to encoder: Encoder) throws {
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(itemType, forKey: .itemType)
            
            if let base = base as? RubbishDashboardConfiguration {
                try container.encode(base, forKey: .base)
            } else if let base = base as? PetrolDashboardConfiguration {
                try container.encode(base, forKey: .base)
            }
            
        }
        
        internal enum CodingKeys: String, CodingKey {
            case itemType = "type"
            case base = "data"
        }
        
    }
    
}
