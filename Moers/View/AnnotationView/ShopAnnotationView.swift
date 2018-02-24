//
//  ShopAnnotationView.swift
//  Moers
//
//  Created by Lennart Fischer on 15.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit

class ShopAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        
        willSet {
            
            clusteringIdentifier = "location"
            markerTintColor = AppColor.yellow //UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1.0)
            glyphTintColor = UIColor.black
            glyphImage = #imageLiteral(resourceName: "shopping-cart")
            
            displayPriority = .defaultHigh
            
            
        }
        
    }
    
}
