//
//  PetrolStationViewModel.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Core
import Foundation
import MapKit
import Fuse

final public class PetrolStationViewModel: LocationViewModel, Location, Codable, MKAnnotation, Identifiable {
    
    public var id: String
    @objc public dynamic var name: String
    public var brand: String
    public var street: String
    public var place: String
    public var houseNumber: String?
    public var postCode: Int?
    public var lat: Double
    public var lng: Double
    public var dist: Double?
    public var diesel: Double? = nil
    public var e5: Double? = nil
    public var e10: Double? = nil
    public var price: Double? = nil
    public var isOpen: Bool
    public var wholeDay: Bool? = nil
    public var openingTimes: [TimeEntry]? = nil
    public var overrides: [String]? = nil
    public var state: String? = nil
    
    public init(
        id: String,
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
        openingTimes: [PetrolStationViewModel.TimeEntry]?,
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
                return Measurement(value: dist, unit: UnitLength.meters)
            } else {
                return Measurement(value: 0, unit: UnitLength.meters)
            }
        }
        set {
            self.dist = newValue.value
        }
    }
    
    // MARK: - MKAnnotation
    
    public var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: lat, longitude: lng) }
    public var title: String? { return self.name.capitalized(with: Locale.autoupdatingCurrent).replacingOccurrences(of: "_", with: " ") }
    public var subtitle: String? { return self.brand }
    
    // MARK: - Categorizable
    
    public var category: String { return "Petrol Station" }
    public var localizedCategory: String { return String(localized: "Petrol Station", bundle: .module) }
    
    // MARK: - Fuse
    
    public var properties: [FuseProperty] {
        return [
            FuseProperty(name: "name", weight: 1)
        ]
    }
    
    public struct TimeEntry: Codable, Equatable {
        
        public var text: String
        public var start: String
        public var end: String
        
        public init(text: String, start: String, end: String) {
            self.text = text
            self.start = start
            self.end = end
        }
        
    }

    
}

extension PetrolStationViewModel: Stubbable {
    
    public static func stub(withID id: ID) -> PetrolStationViewModel {
        return PetrolStationViewModel(
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
