//
//  LocationPreviewModel.swift
//  MMUI
//
//  Created by Lennart Fischer on 26.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import CoreLocation

public struct LocationPreviewModel {

    private enum LocationPreviewError: Error {
        case coordinateNotFound
    }
    
    let name: String
    let coordinate: CLLocationCoordinate2D?
    let street: String?
    let houseNumber: String?
    let postcode: String?
    let place: String?
    
    public init(entry: Entry) {
        
        self.name = entry.name
        self.coordinate = entry.coordinate
        self.street = entry.street
        self.houseNumber = entry.houseNumber
        self.postcode = entry.postcode
        self.place = entry.place
        
    }
    
    public init(name: String, coordinate: CLLocationCoordinate2D?, street: String?, houseNumber: String?, postcode: String?, place: String?) {
        
        self.name = name
        self.coordinate = coordinate
        self.street = street
        self.houseNumber = houseNumber
        self.postcode = postcode
        self.place = place
        
    }
    
    public func mapCoordinate() async throws -> CLLocationCoordinate2D {

        if let coordinate {
            return coordinate
        }

        let geocoder = CLGeocoder()

        let components = [
            street,
            houseNumber,
            postcode ?? "47441",
            place ?? "Moers"
        ]

        let address = components.compactMap { $0 }.reduce("") { "\($0), \($1)" }
        let placemarks = try await geocoder.geocodeAddressString(address)

        if let coordinate = placemarks.first?.location?.coordinate {
            return coordinate
        }

        throw LocationPreviewError.coordinateNotFound

    }
    
}
