//
//  Camera.swift
//  Moers
//
//  Created by Lennart Fischer on 24.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit

typealias PanoID = Int

class Camera: NSObject, Location, MKAnnotation {
    
    var name: String
    var location: CLLocation
    
    var panoID = PanoID()
    
    init(name: String, location: CLLocation, panoID: PanoID) {
        
        self.name = name
        self.location = location
        
        self.panoID = panoID
        
    }
    
    var title: String? { return self.name }
    
    var subtitle: String? { return nil }
    
    var coordinate: CLLocationCoordinate2D { return location.coordinate }
    
    var detailSubtitle: String { return localizedCategory }

    var detailHeight: CGFloat = 80.0
    
    var category: String { return "Camera" }
    
    var localizedCategory: String { return String.localized("Camera") }
    
}
