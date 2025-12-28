//
//  MedicalServiceAnnotationView.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

#if canImport(MapKit)

import SwiftUI
import MapKit

public class MedicalServiceAnnotationView: MKAnnotationView {
    
    private let annotationColor = UIColor.systemGreen //(hexString: "#7C87FE")!
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        //        self.markerTintColor = .systemBlue
        //        self.glyphImage = UIImage(named: "toilet")
        //        self.titleVisibility = .hidden
        //        self.subtitleVisibility = .hidden
        
        //        self.image = buildImage()
        self.image = buildScaledImage()
        
        //        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 10, height: 10)
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1.0
        self.layer.borderColor = annotationColor.cgColor
        self.backgroundColor = annotationColor
        self.canShowCallout = true
        
        self.displayPriority = .defaultLow
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildScaledImage() -> UIImage {
        
        let containerSize = 20.0
        let scaleFactor = 0.6
        let rect = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        
        let result = renderer.image { ctx in
            
            guard let toiletImage = UIImage(systemName: "cross.fill")?.tinted(color: .white) else { return }
            
            let size = containerSize * scaleFactor
            let offset = containerSize / 2.0 - (size / 2.0)
            
            let imageRect = CGRect(x: offset, y: offset, width: size, height: size)
            toiletImage
                .scaled(to: imageRect.size, scalingMode: .aspectFit)
                .draw(in: imageRect)
            
        }
        
        return result
        
    }
    
}

struct MedicalServiceAnnotationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let viewController = AnnotationPreviewController<
            MedicalServiceAnnotationView
        >()
        
        viewController.annotationProducer = { coordinate in
            return MedicalServiceAnnotation(coordinate: coordinate)
        }
        
        return UINavigationController(rootViewController: viewController)
            .preview
            .ignoresSafeArea()
        
    }
    
}

#endif
