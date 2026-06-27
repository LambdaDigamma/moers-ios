//
//  AppleNavigationProvider.swift
//  
//
//  Created by Lennart Fischer on 01.04.22.
//

#if canImport(MapKit)

import Foundation
import MapKit
#if canImport(Contacts)
import Contacts
#endif

@MainActor
public class AppleNavigationProvider: NavigationProvider {
    
    public init() {}
    
    public func startNavigation(to point: Point, withName name: String) {
        
#if os(tvOS)
        return
#else
        let latitude: CLLocationDegrees = point.latitude
        let longitude: CLLocationDegrees = point.longitude
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let options: [String : Any] = [
            MKLaunchOptionsShowsTrafficKey: true
        ]
        
#if canImport(Contacts)
        let address = CNMutablePostalAddress()
        address.street = name
        let placemark = MKPlacemark(coordinate: coordinates, postalAddress: address)
#else
        let placemark = MKPlacemark(coordinate: coordinates)
#endif
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        
        mapItem.openInMaps(launchOptions: options)
#endif
        
    }
    
    public func buildDrivingMapsURL(point: Point) -> URL? {
        
        return URL(string: "https://maps.apple.com/?daddr=\(point.latitude),\(point.longitude)&dirflg=d")
        
    }
    
}

#endif
