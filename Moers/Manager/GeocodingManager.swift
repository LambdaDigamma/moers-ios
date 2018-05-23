//
//  GeocodingManager.swift
//  Moers
//
//  Created by Lennart Fischer on 23.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

struct GeocodingManager {
    
    static let shared = GeocodingManager()
    
    func city(from location: CLLocation, withCompletion completion: @escaping ((String?) -> ())) {
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            if let placemark = placemarks?.first {
                
                let city = placemark.locality
                
                completion(city)
                
            } else {
                
                completion(nil)
                
            }
            
        }
        
    }
    
    func countryCode(from location: CLLocation, withCompletion completion: @escaping ((String?) -> ())) {
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            if let placemark = placemarks?.first {
                
                let country = placemark.isoCountryCode
                
                completion(country)
                
            } else {
                
                completion(nil)
                
            }
            
        }
        
    }
    
}
