//
//  TicketRenderer.swift
//  moers festival
//
//  Created by Lennart Fischer on 17.05.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import Foundation
import MapKit
import SwiftUI

public class TicketRenderer: MKMultiPolygonRenderer {
    
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
        self.rendererStrokeColor = UIColor.systemBlue.withAlphaComponent(0.75)
        self.rendererFillColor = UIColor.systemBlue.lighter(by: 5)?
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
        
        let mapPoint = MKMapPoint(overlay.coordinate)
        let cgPoint = self.point(for: mapPoint)
        
        let size: Double = 20
        let rect = CGRect(
            x: cgPoint.x - (size / 2),
            y: cgPoint.y - (size / 2),
            width: size,
            height: size
        )
        
        context.setFillColor(rendererFillColor.cgColor)
        context.setStrokeColor(rendererStrokeColor.cgColor)
        context.addEllipse(in: rect)
        context.drawPath(using: .fillStroke)
        
    }
    
}

struct TicketRenderer_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let viewController = OverlayRendererPreviewController<TicketRenderer>()
        return UINavigationController(rootViewController: viewController)
            .preview
        
    }
    
}
