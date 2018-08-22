//
//  CameraAnnotationView.swift
//  Moers
//
//  Created by Lennart Fischer on 25.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit

class CameraAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        
        willSet {
            
            if let _ = newValue as? Camera {
                
                clusteringIdentifier = AnnotationIdentifier.cluster
                displayPriority = .defaultLow
                collisionMode = .circle
                markerTintColor = UIColor(red: 0.30, green: 0.85, blue: 0.39, alpha: 1.0) //UIColor(red: 0.188, green: 0.486, blue: 0.208, alpha: 1.00)
                glyphTintColor = UIColor.white
                glyphText = "360°"
                
            }
            
        }
        
    }
    
}
