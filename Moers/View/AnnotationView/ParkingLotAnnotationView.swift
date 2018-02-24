//
//  ParkingLotAnnotationView.swift
//  Moers
//
//  Created by Lennart Fischer on 17.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit

class ParkingLotAnnotationView: MKMarkerAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        
        willSet {
            
            if let _ = newValue as? ParkingLot {
                
                clusteringIdentifier = "location"
                markerTintColor = UIColor(red: 0.00, green: 0.48, blue: 1.00, alpha: 1.0)
                glyphTintColor = UIColor.white
                glyphText = "P"
                displayPriority = .defaultHigh
                
            }
            
        }
        
    }
    
}
