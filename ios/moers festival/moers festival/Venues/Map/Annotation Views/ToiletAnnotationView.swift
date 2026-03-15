//
//  ToiletAnnotationView.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

#if canImport(MapKit)

import SwiftUI
import MapKit

public class ToiletAnnotationView: MKAnnotationView {
    
    private let annotationColor = UIColor(hexString: "#7C87FE")!
    
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
    
    private func buildImage() -> UIImage {
        
        let containerSize = 10.0
        let scaleFactor = 0.8
        let rect = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        
        let result = renderer.image { ctx in
            
            let context = ctx.cgContext
            
            context.setFillColor(UIColor.systemBlue.cgColor)
            context.addEllipse(in: rect)
            context.drawPath(using: .fill)
            
            guard let toiletImage = UIImage(named: "toilet")?.tinted(color: .white) else { return }
            
            let size = containerSize * scaleFactor
            let offset = containerSize / 2.0 - (size / 2.0)
            
            let imageRect = CGRect(x: offset, y: offset, width: size, height: size)
            toiletImage.draw(in: imageRect)
            
        }
        
        return result
        
    }
    
    private func buildScaledImage() -> UIImage {
        
        let containerSize = 20.0
        let scaleFactor = 0.8
        let rect = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        
        let result = renderer.image { ctx in

//            let context = ctx.cgContext

//            context.setFillColor(UIColor.systemBlue.cgColor)
//            context.addEllipse(in: rect)
//            context.drawPath(using: .fill)

            guard let toiletImage = UIImage(named: "toilet")?.tinted(color: .white) else { return }
            
            let size = containerSize * scaleFactor
            let offset = containerSize / 2.0 - (size / 2.0)
            
            let imageRect = CGRect(x: offset, y: offset, width: size, height: size)
            toiletImage.draw(in: imageRect)
            
        }
        
        return result
        
    }
    
}

struct ToiletAnnotationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let viewController = AnnotationPreviewController<
            ToiletAnnotationView
        >()
        
        viewController.annotationProducer = { coordinate in
            return ToiletAnnotation(title: "Toiletten", coordinate: coordinate)
        }
        
        return UINavigationController(rootViewController: viewController)
            .preview
            .ignoresSafeArea()
        
    }
    
}

#endif
