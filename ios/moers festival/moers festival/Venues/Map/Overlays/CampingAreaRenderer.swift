//
//  CampingAreaRenderer.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Foundation
import MapKit
import SwiftUI

public class CampingAreaRenderer: MKMultiPolygonRenderer {
    
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
        self.rendererStrokeColor = UIColor.systemBrown.withAlphaComponent(0.75)
        self.rendererFillColor = UIColor.systemBrown.lighter(by: 5)?
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
        
    }
    
}

struct CampingAreaRenderer_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let viewController = OverlayRendererPreviewController<CampingAreaRenderer>()
        return UINavigationController(rootViewController: viewController)
            .preview
        
    }
    
}
