//
//  TrackerAnnotationView.swift
//  moers festival
//
//  Created by Lennart Fischer on 24.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import MapKit

class TrackerAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            
            glyphImage = UIImage(named: "pianoMobil_shape")
            markerTintColor = AppColors.navigationAccent
            glyphTintColor = UIColor.black
            displayPriority = .defaultHigh
            collisionMode = .circle
            
        }
    }
    
}
