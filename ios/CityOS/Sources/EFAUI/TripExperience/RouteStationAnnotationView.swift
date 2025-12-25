//
//  RouteStationAnnotationView.swift
//  
//
//  Created by Lennart Fischer on 27.12.22.
//

import Foundation
import MapKit
import Core
import SwiftUI

public class RouteStationAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 10, height: 10)
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor(Color.routeLine).cgColor
        self.layer.backgroundColor = UIColor.white.cgColor
        self.canShowCallout = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
