//
//  MedicalServiceRenderer.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Foundation
import MapKit
import SwiftUI

public class MedicalServiceRenderer: MKMultiPolygonRenderer {
    
    private var rendererLineWidth: CGFloat = 1
    private var rendererStrokeColor: UIColor = UIColor.clear
    private var rendererFillColor: UIColor = UIColor.clear
    
    public override init(overlay: MKOverlay) {
        super.init(overlay: overlay)
        
        self.setupColors()
    }
    
    public override init(multiPolygon: MKMultiPolygon) {
        super.init(multiPolygon: multiPolygon)
        
        self.setupColors()
    }
    
    private func setupColors() {
        
        self.rendererLineWidth = 1
        self.rendererStrokeColor = UIColor.systemGreen.withAlphaComponent(0.75)
        self.rendererFillColor = UIColor.systemGreen.lighter(by: 5)?
            .withAlphaComponent(0.3) ?? .clear
        
        self.lineWidth = rendererLineWidth
        self.strokeColor = rendererStrokeColor
        self.fillColor = rendererFillColor
        
    }
    
    public override func draw(
        _ mapRect: MKMapRect,
        zoomScale: MKZoomScale,
        in context: CGContext
    ) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)
        
        let symbol = UIImage(systemName: "cross.circle.fill")?
            .tinted(color: UIColor.systemGreen)
        
        guard let image = symbol?.cgImage else { return }
        let mapPoint = MKMapPoint(overlay.coordinate)
        let cgPoint = self.point(for: mapPoint)
        
        let size: Double = 30
        let rect = CGRect(
            x: cgPoint.x - (size / 2),
            y: cgPoint.y - (size / 2),
            width: size,
            height: size
        )
        
//        image.draw(in: rect)
        
        context.draw(image, in: rect)
        
//        context.setFillColor(rendererFillColor.cgColor)
//        context.setStrokeColor(rendererStrokeColor.cgColor)
//        context.addEllipse(in: rect)
//        context.drawPath(using: .fillStroke)
        
    }
    
}

struct MedicalServiceRenderer_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let viewController = OverlayRendererPreviewController<MedicalServiceRenderer>()
        return UINavigationController(rootViewController: viewController)
            .preview
        
    }
    
}
