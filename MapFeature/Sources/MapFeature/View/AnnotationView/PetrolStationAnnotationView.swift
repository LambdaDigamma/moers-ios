//
//  PetrolStationAnnotationView.swift
//  Moers
//
//  Created by Lennart Fischer on 21.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit

class PetrolStationAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        
        willSet {
            
            collisionMode = .circle
            clusteringIdentifier = AnnotationIdentifier.cluster
            displayPriority = .defaultHigh
            markerTintColor = UIColor(hexString: "#D32F2F")
            glyphTintColor = UIColor.white
            glyphImage = #imageLiteral(resourceName: "petrolGlyph")
            
        }
        
    }
    
}
