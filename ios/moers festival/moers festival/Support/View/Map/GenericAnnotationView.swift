//
//  GenericAnnotationView.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.06.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import MapKit

class GenericAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            
            clusteringIdentifier = AnnotationIdentifier.cluster
            markerTintColor = UIColor(dynamicProvider: { (traitCollection: UITraitCollection) in
                return traitCollection.userInterfaceStyle == .dark ? .systemYellow : .black
            })
            
            glyphTintColor = UIColor(dynamicProvider: { (traitCollection: UITraitCollection) in
                return traitCollection.userInterfaceStyle == .dark ? .black : .white
            })
            
            glyphImage = UIImage(systemName: "music.note")
            
            displayPriority = .defaultHigh
            collisionMode = .circle
            titleVisibility = .hidden
            
            
        }
    }
    
}

