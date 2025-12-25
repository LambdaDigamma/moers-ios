//
//  Place.swift
//  
//
//  Created by Lennart Fischer on 25.04.21.
//

import Core
import Foundation
import ModernNetworking

public struct Place: Model, Stubbable {
    
    public typealias ID = Int
    
    public let id: ID
    public let lat: Double
    public let lng: Double
    public let name: String
    public let streetName: String?
    public let streetNumber: String?
    public let streetAddition: String?
    public let postalCode: String?
    public let postalTown: String?
    public let countryCode: String?
//    public let openingHours:
    public let tags: String
    public let url: String?
    public let phone: String?
    public let pageID: Page.ID?
    public let validatedAt: Date?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let deletedAt: Date?
    public var events: [Event] = []
    
    public init(
        id: Place.ID,
        lat: Double,
        lng: Double,
        name: String,
        streetName: String?,
        streetNumber: String?,
        streetAddition: String?,
        postalCode: String?,
        postalTown: String?,
        countryCode: String?,
        tags: String,
        url: String?,
        phone: String?,
        pageID: Page.ID? = nil,
        validatedAt: Date?,
        createdAt: Date?,
        updatedAt: Date?,
        deletedAt: Date?,
        events: [Event] = []
    ) {
        self.id = id
        self.lat = lat
        self.lng = lng
        self.name = name
        self.streetName = streetName
        self.streetNumber = streetNumber
        self.streetAddition = streetAddition
        self.postalCode = postalCode
        self.postalTown = postalTown
        self.countryCode = countryCode
        self.tags = tags
        self.url = url
        self.phone = phone
        self.pageID = pageID
        self.validatedAt = validatedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.events = events
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(ID.self, forKey: .id)
        self.lat = try container.decode(Double.self, forKey: .lat)
        self.lng = try container.decode(Double.self, forKey: .lng)
        self.name = try container.decode(String.self, forKey: .name)
        self.streetName = try container.decode(String?.self, forKey: .streetName)
        self.streetNumber = try container.decode(String?.self, forKey: .streetNumber)
        self.streetAddition = try container.decodeIfPresent(String?.self, forKey: .streetAddition) ?? nil
        self.postalCode = try container.decode(String?.self, forKey: .postalCode)
        self.postalTown = try container.decode(String?.self, forKey: .postalTown)
        self.countryCode = try container.decode(String?.self, forKey: .countryCode)
        self.tags = try container.decode(String.self, forKey: .tags)
        self.url = try container.decode(String?.self, forKey: .url)
        self.phone = try container.decode(String?.self, forKey: .phone)
        self.pageID = try container.decodeIfPresent(Page.ID.self, forKey: .pageID)
        self.validatedAt = try container.decode(Date?.self, forKey: .validatedAt)
        self.createdAt = try container.decode(Date?.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date?.self, forKey: .updatedAt)
        self.deletedAt = try container.decode(Date?.self, forKey: .deletedAt)
        self.events = try container.decodeIfPresent([Event].self, forKey: .events) ?? []
    }
    
    public func encode(to encoder: Encoder) throws {
    
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(lat, forKey: .lat)
        try container.encode(lng, forKey: .lng)
        try container.encode(name, forKey: .name)
        try container.encode(streetName, forKey: .streetName)
        try container.encode(streetNumber, forKey: .streetNumber)
        try container.encodeIfPresent(streetAddition, forKey: .streetAddition)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(postalTown, forKey: .postalTown)
        try container.encode(countryCode, forKey: .countryCode)
        try container.encode(tags, forKey: .tags)
        try container.encode(url, forKey: .url)
        try container.encode(phone, forKey: .phone)
        try container.encode(pageID, forKey: .pageID)
        try container.encode(validatedAt, forKey: .validatedAt)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(deletedAt, forKey: .deletedAt)
        try container.encodeIfPresent(events, forKey: .events)
        
    }
    
    public enum CodingKeys: String, CodingKey {
        case id, lat, lng, name, tags, url, phone, events
        case streetName = "street_name"
        case streetNumber = "street_number"
        case streetAddition = "address_addition"
        case postalCode = "postalcode"
        case postalTown = "postal_town"
        case countryCode = "country_code"
        case pageID = "page_id"
        case validatedAt = "validated_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    public static func stub(withID id: Int) -> Place {
        return Place(
            id: 1,
            lat: 51.440105,
            lng: 6.619091,
            name: "Festivalhalle",
            streetName: "Filderstraße",
            streetNumber: "142",
            streetAddition: nil,
            postalCode: "47447",
            postalTown: "Moers",
            countryCode: "DE",
            tags: "",
            url: nil,
            phone: nil,
            validatedAt: Date(),
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil
        )
    }
    
    public var coordinate: Point? {
        return Point(latitude: lat, longitude: lng)
    }
    
}

extension Place {
    
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        return decoder
    }
    
}
