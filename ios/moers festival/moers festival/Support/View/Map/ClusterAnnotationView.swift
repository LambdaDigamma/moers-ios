//
//  ClusterAnnotationView.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.06.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit
import MapKit

class ClusterAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        
        willSet {
            
            glyphTintColor = UIColor.white
            markerTintColor = UIColor.black
            
        }
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
