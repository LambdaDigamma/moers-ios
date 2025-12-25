//
//  ParkingAreaAnnotationView.swift
//  
//
//  Created by Lennart Fischer on 01.02.22.
//

import Foundation
import MapKit

public class ParkingAreaAnnotationView: MKMarkerAnnotationView {
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
//        let configuration = UIImage.SymbolConfiguration(pointSize: 6, weight: .semibold)
        
//        self.glyphImage = UIImage(systemName: "parkingsign", withConfiguration: configuration)
        self.glyphText = "P"
        self.markerTintColor = UIColor.systemBlue
        self.glyphTintColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update() {
        
    }
    
    public static let reuseIdentifier = "parking_area_annotation_view"
    
}
