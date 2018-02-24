//
//  BikeChargingStationAnnotationView.swift
//  Moers
//
//  Created by Lennart Fischer on 11.11.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import MapKit

class BikeChargingStationAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        
        willSet {
            
            if let _ = newValue as? BikeChargingStation {
                
                clusteringIdentifier = "location"
                markerTintColor = UIColor(red: 0.365, green: 0.780, blue: 0.973, alpha: 1.00)
                glyphImage = #imageLiteral(resourceName: "bicycle")
                
                displayPriority = .defaultHigh
                
            }
            
        }
        
    }
    
}
