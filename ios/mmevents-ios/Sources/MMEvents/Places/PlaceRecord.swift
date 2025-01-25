//
//  PlaceRecord.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import GRDB

public struct PlaceRecord: Equatable {
    
    public var id: Int64?
    public var latitude: Double
    public var longitude: Double
    public var name: String
    public var streetName: String?
    public var streetNumber: String?
    public var streetAddition: String?
    public var postalCode: String?
    public var postalTown: String?
    public var countryCode: String?
    
    public var pageID: Int64?
    public var validatedAt: Date?
    public var createdAt: Date?
    public var updatedAt: Date?
    
    public var deletedAt: Date?
    
}

extension PlaceRecord: Codable, FetchableRecord, MutablePersistableRecord {
    
    public static var databaseTableName: String = PlaceTableDefinition.tableName
    
    public static var databaseColumnDecodingStrategy: DatabaseColumnDecodingStrategy = .convertFromSnakeCase
    public static var databaseColumnEncodingStrategy: DatabaseColumnEncodingStrategy = .convertToSnakeCase
    
    internal enum Columns {
        static let name = Column(CodingKeys.name)
    }
    
    public static let events = hasMany(EventRecord.self)
    
    public var events: QueryInterfaceRequest<EventRecord> {
        request(for: PlaceRecord.events)
    }
    
}

extension PlaceRecord {
    
    public func toBase() -> Place {
        
        return Place(
            id: self.id.toInt() ?? 0,
            lat: self.latitude,
            lng: self.longitude,
            name: self.name,
            streetName: self.streetName,
            streetNumber: self.streetNumber,
            streetAddition: self.streetAddition,
            postalCode: self.postalCode,
            postalTown: self.postalTown,
            countryCode: self.countryCode,
            tags: "",
            url: nil,
            phone: nil,
            pageID: self.pageID.toInt(),
            validatedAt: self.validatedAt,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            deletedAt: self.deletedAt,
            events: []
        )
        
    }
    
}

extension Place {
    
    public func toRecord() -> PlaceRecord {
        
        return PlaceRecord(
            id: self.id.toInt64(),
            latitude: self.lat,
            longitude: self.lng,
            name: self.name,
            streetName: self.streetName,
            streetNumber: self.streetNumber,
            streetAddition: self.streetAddition,
            postalCode: self.postalCode,
            postalTown: self.postalTown,
            countryCode: self.countryCode,
            pageID: self.pageID?.toInt64(),
            validatedAt: self.validatedAt,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            deletedAt: self.deletedAt
        )
        
    }
    
}
