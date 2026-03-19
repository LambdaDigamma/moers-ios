//
//  FestivalhalleMapOverlayView.swift
//  moers festival
//
//  Created by Lennart Fischer on 29.01.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit
import MapKit

class FestivalhalleMapOverlayView: MKOverlayRenderer {
    
    var overlayImage: UIImage
    
    nonisolated init(overlay: MKOverlay, overlayImage: UIImage) {
        self.overlayImage = overlayImage
        super.init(overlay: overlay)
    }

    nonisolated override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        
        guard let imageReference = overlayImage.cgImage else { return }
        
        let rect = self.rect(for: overlay.boundingMapRect)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -rect.size.height)
        context.draw(imageReference, in: rect)
        
    }
    
}
