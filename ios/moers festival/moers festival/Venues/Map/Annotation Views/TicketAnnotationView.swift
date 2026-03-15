//
//  TicketAnnotationView.swift
//  moers festival
//
//  Created by Lennart Fischer on 17.05.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import Foundation

#if canImport(MapKit)

import SwiftUI
import MapKit

public class TicketAnnotationView: MKAnnotationView {
    
    private let foregroundColor = UIColor.white
    private let containerColor = UIColor(hexString: "#7C87FE")!
    
    let size: CGFloat = 30
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        //        self.markerTintColor = .systemBlue
        //        self.glyphImage = UIImage(named: "toilet")
        //        self.titleVisibility = .hidden
        //        self.subtitleVisibility = .hidden
        
        //        self.image = buildImage()
        self.image = buildScaledImage()
        
        //        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 10, height: 10)
        self.layer.cornerRadius = size / 2
        //        self.layer.borderWidth = 1.0
        //        self.layer.borderColor = annotationColor.cgColor
        self.backgroundColor = containerColor
        self.canShowCallout = true
        
        self.displayPriority = .defaultHigh
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    private func buildScaledImage() -> UIImage {
//        
//        let containerSize = 20.0
//        let scaleFactor = 1.0
//        let rect = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
//        let renderer = UIGraphicsImageRenderer(size: rect.size)
//        
//        let result = renderer.image { ctx in
//            
//            //            let context = ctx.cgContext
//            
//            //            context.setFillColor(UIColor.systemBlue.cgColor)
//            //            context.addEllipse(in: rect)
//            //            context.drawPath(using: .fill)
//            
//            guard let image = UIImage(systemName: "ticket.fill")?
//                .tinted(color: .black) else { return }
//            
//            let size = containerSize * scaleFactor
//            let offset = containerSize / 2.0 - (size / 2.0)
//            
//            let imageRect = CGRect(x: offset, y: offset, width: size, height: size)
//            image.draw(in: imageRect)
//            
//        }
//        
//        return result
//        
//    }
    
    private func buildScaledImage() -> UIImage {
        let containerSize: CGFloat = size
        let scaleFactor: CGFloat = 0.9 // Adjust as needed
        let rect = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        
        let result = renderer.image { ctx in
            
            guard let image = UIImage(
                systemName: "info.circle"
            )?.tinted(color: foregroundColor) else { return }
            
            // Calculate the scaled size of the image
            let scaledWidth = image.size.width * scaleFactor
            let scaledHeight = image.size.height * scaleFactor
            
            // Calculate the position to center the image within the container
            let xOffset = (containerSize - scaledWidth) / 2.0
            let yOffset = (containerSize - scaledHeight) / 2.0
            
            // Define the rectangle where the image will be drawn
            let imageRect = CGRect(x: xOffset, y: yOffset, width: scaledWidth, height: scaledHeight)
            
            // Draw the image in the calculated rectangle
            image.draw(in: imageRect)
        }
        
        return result
    }
    
}

struct TicketAnnotationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let viewController = AnnotationPreviewController<
            TicketAnnotationView
        >()
        
        viewController.annotationProducer = { coordinate in
            return TicketAnnotation(title: "Tickets", coordinate: coordinate)
        }
        
        return UINavigationController(rootViewController: viewController)
            .preview
            .ignoresSafeArea()
        
    }
    
}

#endif

