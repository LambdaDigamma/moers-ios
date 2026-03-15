//
//  VenueAnnotationView.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

#if canImport(MapKit)

import SwiftUI
import MapKit

public class AlternativeVenueAnnotationView: MKAnnotationView {
    
    private let size: CGFloat = 30.0
    private let annotationColor = UIColor(hexString: "#000000")!
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
//        self.markerTintColor = .systemBlue
//        self.glyphImage = UIImage(named: "toilet")
//        self.titleVisibility = .hidden
//        self.subtitleVisibility = .hidden

//        self.image = buildImage()
        self.image = buildScaledImage()
        
//        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: size, height: size)
        self.layer.cornerRadius = 4 // self.layer.frame.height / 2
        self.layer.borderWidth = 1.0
        self.layer.borderColor = annotationColor.cgColor
        self.backgroundColor = annotationColor
        self.canShowCallout = false
        
        
        self.displayPriority = .defaultHigh
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildScaledImage() -> UIImage {
        
        let containerSize = 20.0
        let scaleFactor = 0.65
        let rect = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        
        let result = renderer.image { ctx in
            
            let configuration = UIImage.SymbolConfiguration(weight: .heavy)
            
            guard let toiletImage = UIImage(
                systemName: "music.mic",
                withConfiguration: configuration
            )?.tinted(color: .white) else { return }
            
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

public class VenueAnnotationView: MKMarkerAnnotationView {
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        
//        let configuration = UIImage.SymbolConfiguration(weight: .semibold)
//        let symbol = UIImage(
//            systemName: "music.mic",
//            withConfiguration: configuration
//        )
//        self.glyphImage = symbol
//        self.markerTintColor = UIColor.black
        self.glyphTintColor = UIColor.white
        self.displayPriority = .defaultHigh
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct VenueAnnotationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let viewController = AnnotationPreviewController<
            VenueAnnotationView
        >()
        
        viewController.annotationProducer = { coordinate in
            return VenueAnnotation(title: "Festivalhalle", coordinate: coordinate, placeID: 1)
        }
        
        return UINavigationController(rootViewController: viewController)
            .preview
            .preferredColorScheme(.light)
            .ignoresSafeArea()
        
    }
    
}

#endif

