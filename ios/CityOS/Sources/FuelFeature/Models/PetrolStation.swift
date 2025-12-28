//
//  PetrolStation.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import MapKit
import Fuse
import Core

// swiftlint:disable identifier_name
final public class PetrolStation: NSObject, Location, Codable, MKAnnotation, Swift.Identifiable, MKRepresentable {
    
    public typealias ID = String
    
    public var id: PetrolStation.ID
    @objc public dynamic var name: String
    public var brand: String
    public var street: String
    public var place: String
    public var houseNumber: String?
    public var postCode: Int?
    public var lat: Double
    public var lng: Double
    public var dist: Double?
    public var diesel: Double?
    public var e5: Double?
    public var e10: Double?
    public var price: Double?
    public var isOpen: Bool
    public var wholeDay: Bool?
    public var openingTimes: [PetrolStationTimeEntry]?
    public var overrides: [String]?
    public var state: String?
    
    public init(
        id: PetrolStation.ID,
        name: String,
        brand: String,
        street: String,
        place: String,
        houseNumber: String?,
        postCode: Int?,
        lat: Double,
        lng: Double,
        dist: Double?,
        diesel: Double?,
        e5: Double?,
        e10: Double?,
        price: Double?,
        isOpen: Bool,
        wholeDay: Bool?,
        openingTimes: [PetrolStationTimeEntry]?,
        overrides: [String]?,
        state: String?
    ) {
        
        self.id = id
        self.name = name
        self.brand = brand
        self.street = street
        self.place = place
        self.houseNumber = houseNumber
        self.postCode = postCode
        self.lat = lat
        self.lng = lng
        self.dist = dist
        self.diesel = diesel
        self.e5 = e5
        self.e10 = e10
        self.price = price
        self.isOpen = isOpen
        self.wholeDay = wholeDay
        self.openingTimes = openingTimes
        self.overrides = overrides
        self.state = state
        
    }
    
    // MARK: - Location
    
    public var location: CLLocation { return CLLocation(latitude: self.lat, longitude: self.lng) }
    
    public var tags: [String] {
        return [localizedCategory, "Tanken", "Diesel", "E5", "E10"]
    }
    
    public var distance: Measurement<UnitLength> {
        get {
            if let dist = dist {
                return Measurement(value: dist, unit: UnitLength.kilometers)
            } else {
                return Measurement(value: 0, unit: UnitLength.kilometers)
            }
        }
        set {
            self.dist = newValue.value
        }
    }
    
    // MARK: - MKAnnotation
    
    public var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: lat, longitude: lng) }
    public var title: String? { return self.name.capitalized(with: Locale.autoupdatingCurrent).replacingOccurrences(of: "_", with: " ") }
    public var subtitle: String? {
        
        var attributes: [String] = []
        
        if dist != nil {
            attributes.append(Self.distanceFormatter.string(from: distance))
        }
        
        attributes.append("\(self.street) \(self.houseNumber ?? "")")
        
        return attributes.joined(separator: " · ")
        
    }
    
    // MARK: - Categorizable
    
    public var category: String { return "Petrol Station" }
    public var localizedCategory: String { return String(localized: "Petrol Station", bundle: .module) }
    
    // MARK: - Fuse
    
    public var properties: [FuseProperty] {
        return [
            FuseProperty(name: "name", weight: 1)
        ]
    }
    
    #if canImport(MapKit)
    
    public func toMapItem() -> MKMapItem {
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: self.coordinate))
        mapItem.name = self.name
        mapItem.pointOfInterestCategory = .gasStation
        
        return mapItem
        
    }
    
    #endif
    
    public static let distanceFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = [.providedUnit]
        return formatter
    }()
    
}

extension PetrolStation: Core.Stubbable {
    
    public static func stub(withID id: ID) -> PetrolStation {
        return PetrolStation(
            id: id,
            name: "Petrol Station",
            brand: "",
            street: "Musterstraße",
            place: "Musterdorf",
            houseNumber: nil,
            postCode: nil,
            lat: 0.0,
            lng: 0.0,
            dist: nil,
            diesel: nil,
            e5: nil,
            e10: nil,
            price: nil,
            isOpen: true,
            wholeDay: nil,
            openingTimes: nil,
            overrides: nil,
            state: nil
        )
    }
    
}
