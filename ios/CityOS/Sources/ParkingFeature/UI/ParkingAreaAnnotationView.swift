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
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        
        if let image = UIImage(systemName: "parkingsign", withConfiguration: configuration) {
            self.glyphImage = image
        }
        self.markerTintColor = UIColor.systemBlue
        self.glyphTintColor = UIColor.white
        self.displayPriority = .defaultHigh
        self.canShowCallout = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update() {
        
    }
    
    public static let reuseIdentifier = "parking_area_annotation_view"
    
}
