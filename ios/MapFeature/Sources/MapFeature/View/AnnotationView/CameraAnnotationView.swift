//
//  CameraAnnotationView.swift
//  Moers
//
//  Created by Lennart Fischer on 25.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Core
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
            
            if newValue as? Camera != nil {
                
                clusteringIdentifier = AnnotationIdentifier.cluster
                displayPriority = .defaultLow
                collisionMode = .circle
                markerTintColor = UIColor(red: 0.30, green: 0.85, blue: 0.39, alpha: 1.0)
                glyphTintColor = UIColor.black
                glyphText = "360°"
                
            }
            
        }
        
    }
    
}
