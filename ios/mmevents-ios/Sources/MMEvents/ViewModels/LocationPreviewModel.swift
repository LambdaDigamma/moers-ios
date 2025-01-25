//
//  LocationPreviewModel.swift
//  
//
//  Created by Lennart Fischer on 14.06.21.
//

import Core
import Foundation
import CoreLocation
import Combine

public struct LocationPreviewModel {
    
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
    
    public init(
        name: String,
        coordinate: CLLocationCoordinate2D?,
        street: String?,
        houseNumber: String?,
        postcode: String?,
        place: String?
    ) {
        
        self.name = name
        self.coordinate = coordinate
        self.street = street
        self.houseNumber = houseNumber
        self.postcode = postcode
        self.place = place
        
    }
    
    public var mapCoordinate: AnyPublisher<CLLocationCoordinate2D, Error> {
        
        let geocoder = CLGeocoder()
        
        return Deferred {
            return Future { promise in
                
                if let coordinate = self.coordinate {
                    promise(.success(coordinate))
                }
                
                let components = [
                    self.street,
                    self.houseNumber,
                    self.postcode ?? "47441",
                    self.place ?? "Moers"
                ]
                
                let address = components.compactMap { $0 }.reduce("") { "\($0), \($1)" }
                
                geocoder.geocodeAddressString(address) { (placemarks, error) in
                    
                    if let error = error {
                        promise(.failure(error))
                    }
                    
                    if let placemark = placemarks?.first,
                       let coordinate = placemark.location?.coordinate {
                        promise(.success(coordinate))
                    }
                    
                }
                
            }
        }.handleEvents(receiveCancel: {
            geocoder.cancelGeocode()
        })
        .eraseToAnyPublisher()
        
    }
    
}
