//
//  TransitStationAnnotationView.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import Foundation
import MapKit
import Core
import SwiftUI

public class TransitStationAnnotationView: MKMarkerAnnotationView {
    
    public override var annotation: MKAnnotation? {
        willSet {
            if let annotation = annotation as? TransitStationAnnotation {
                self.glyphImage = UIImage(systemName: annotation.transitStationType.imageName)
            }
        }
    }
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        self.glyphTintColor = .white
        self.markerTintColor = UIColor(Color.routeLine)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
