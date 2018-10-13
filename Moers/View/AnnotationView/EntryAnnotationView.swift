//
//  EntryAnnotationView.swift
//  Moers
//
//  Created by Lennart Fischer on 11.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit

class EntryAnnotationView: MKMarkerAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            
            clusteringIdentifier = AnnotationIdentifier.cluster
            displayPriority = .defaultHigh
            collisionMode = .circle
            markerTintColor = AppColor.yellow
            glyphTintColor = UIColor.black
            
        }
    }

}
