//
//  DorfAnnotationView.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import MapKit

class DorfAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 10, height: 10)
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.backgroundColor = UIColor.black.cgColor
        self.canShowCallout = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct PointAnnotationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let viewController = AnnotationPreviewController<
            DorfAnnotationView
        >()
        
        viewController.annotationProducer = { coordinate in
            return DorfAnnotation(title: "Knobibrot", coordinate: coordinate)
        }
        
        return UINavigationController(rootViewController: viewController)
            .preview
            .ignoresSafeArea()
        
    }
    
}
