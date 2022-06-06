//
//  AppleNavigationProvider.swift
//  
//
//  Created by Lennart Fischer on 01.04.22.
//

#if canImport(MapKit)

import Foundation
import MapKit
import Contacts

public class AppleNavigationProvider: NavigationProvider {
    
    public init() {}
    
    public func startNavigation(to point: Point, withName name: String) {
        
        let latitude: CLLocationDegrees = point.latitude
        let longitude: CLLocationDegrees = point.longitude
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let options: [String : Any] = [
            MKLaunchOptionsShowsTrafficKey: true
        ]
        
        let address = CNMutablePostalAddress()
        address.street = name

        let placemark = MKPlacemark(coordinate: coordinates, postalAddress: address)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        
        mapItem.openInMaps(launchOptions: options)
        
    }
    
}

#endif
