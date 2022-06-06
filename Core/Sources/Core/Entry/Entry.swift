//
//  Entry.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import MapKit
import Fuse
import ModernNetworking
//import MMCommon

public class Entry: NSObject, Decodable, Location, Model {
    
    public var id: Int
    @objc dynamic public var name: String
    public var tags: [String] = []
    public var street: String
    public var streetNumber: String? = ""
    public var houseNumber: String? = ""
    public var postcode: String
    public var place: String
    public var url: String?
    public var phone: String?
    public var monday: String?
    public var tuesday: String?
    public var wednesday: String?
    public var thursday: String?
    public var friday: String?
    public var saturday: String?
    public var sunday: String?
    public var other: String?
    public var isValidated: Bool = true
    private let lat: Double
    private let lng: Double
    
    public var createdAt: Date?
    public var updatedAt: Date?
    
    public init(id: Int, name: String, tags: [String], street: String, houseNumber: String, postcode: String, place: String, url: String?, phone: String?, monday: String?, tuesday: String?, wednesday: String?, thursday: String?, friday: String?, saturday: String?, sunday: String?, other: String?, lat: Double, lng: Double, isValidated: Bool) {
        
        self.id = id
        self.name = name
        self.tags = tags
        self.street = street
        self.houseNumber = houseNumber
        self.postcode = postcode
        self.place = place
        self.url = url
        self.phone = phone
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
        self.other = other
        self.lat = lat
        self.lng = lng
        self.isValidated = isValidated
        
    }
    
    public init(id: Int, name: String, street: String, houseNumber: String, postcode: String, place: String, lat: Double, lng: Double) {
        
        self.id = id
        self.name = name
        self.street = street
        self.houseNumber = houseNumber
        self.postcode = postcode
        self.place = place
        self.lat = lat
        self.lng = lng
        self.createdAt = Date()
        self.updatedAt = Date()
        
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        do {
            self.tags = try container.decode([String].self, forKey: .tags)
        } catch {
            self.tags = ((try? container.decode(String.self, forKey: .tags)) ?? "")?
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? []
        }
        
        self.street = (try? container.decodeIfPresent(String.self, forKey: .street))
            ?? (try? container.decodeIfPresent(String.self, forKey: .street))
            ?? ""
        self.streetNumber = try container.decodeIfPresent(String.self, forKey: .streetNumber)
        self.houseNumber = try container.decodeIfPresent(String.self, forKey: .houseNumber)
        self.postcode = try container.decode(String.self, forKey: .postcode)
        self.place = try container.decode(String.self, forKey: .place)
        self.url = try container.decode(String.self, forKey: .url)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.monday = try container.decode(String.self, forKey: .monday)
        self.tuesday = try container.decode(String.self, forKey: .tuesday)
        self.wednesday = try container.decode(String.self, forKey: .wednesday)
        self.thursday = try container.decode(String.self, forKey: .thursday)
        self.friday = try container.decode(String.self, forKey: .friday)
        self.saturday = try container.decode(String.self, forKey: .saturday)
        self.sunday = try container.decode(String.self, forKey: .sunday)
        self.other = try container.decode(String.self, forKey: .other)
        self.isValidated = try container.decodeIfPresent(Bool.self, forKey: .isValidated) ?? true
        self.lat = try container.decode(Double.self, forKey: .lat)
        self.lng = try container.decode(Double.self, forKey: .lng)
        
        self.createdAt = try container.decode(Date?.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date?.self, forKey: .updatedAt)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
    }
    
    // MARK: - Location
    
    public var location: CLLocation { return CLLocation(latitude: lat, longitude: lng) }
    
    public var distance: Measurement<UnitLength> = Measurement(value: 0, unit: UnitLength.meters)
    
    // MARK: - MKAnnotation
    
    public var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: lat, longitude: lng) }
    public var title: String? { return self.name }
    public var subtitle: String? { return self.street + " " + (self.houseNumber ?? "") }
    
    // MARK: - Categorizable
    
    public var category: String { return "Entry" }
    public var localizedCategory: String { return "Eintrag" } // TODO: Localize this
    
    // MARK: - Fuse
    
    public var properties: [FuseProperty] {
        return [
            FuseProperty(name: "name", weight: 1)
        ]
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case street = "street_name"
        case streetName = "street"
        case houseNumber = "house_number"
        case streetNumber = "street_number"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isValidated = "is_validated"
        case id, tags, postcode, place, url, phone, monday, tuesday, wednesday, thursday, friday, saturday, sunday, other, lat, lng
    }
    
}

extension Entry {
    
    public override var debugDescription: String {
        return "Entry(id: \(id), name: \(name), tags: \(tags), street: \(street)"
    }
    
//    public static var decoder: JSONDecoder {
//
//        let decoder = JSONDecoder()
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.timeZone = TimeZone(abbreviation: "UTC")
//
//        decoder.keyDecodingStrategy = .useDefaultKeys
//        decoder.dateDecodingStrategy = .formatted(formatter)
//
//        return decoder
//
//    }
//
//    public static var encoder: JSONEncoder {
//
//        let encoder = JSONEncoder()
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.timeZone = TimeZone(abbreviation: "UTC")
//
//        encoder.keyEncodingStrategy = .useDefaultKeys
//        encoder.dateEncodingStrategy = .formatted(formatter)
//
//        return encoder
//
//    }
    
}
