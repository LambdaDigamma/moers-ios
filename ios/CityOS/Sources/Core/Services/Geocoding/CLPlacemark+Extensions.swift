//
//  CLPlacemark+Extensions.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import CoreLocation

public extension CLPlacemark {
    
    /// Wrapping the placemarks `locality` property
    /// to make it easier for europeans to handle
    /// placemarks during development.
    var city: String {
        return self.locality ?? ""
    }
    
    /// Wrapping the placemarks `isoCountryCode` property
    /// to make it easier for europeans to handle
    /// placemarks during development.
    var countryCode: String {
        return self.isoCountryCode ?? ""
    }
    
    /// Wrapping the placemarks `thoroughfare` property
    /// to make it easier for europeans to handle
    /// placemarks during development.
    var street: String {
        return self.thoroughfare ?? ""
    }
    
    /// Wrapping the placemarks `subThoroughfare` property
    /// to make it easier for europeans to handle
    /// placemarks during development.
    var houseNumber: String {
        return self.subThoroughfare ?? ""
    }
    
}
