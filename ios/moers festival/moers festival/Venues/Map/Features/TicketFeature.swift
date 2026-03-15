//
//  TicketFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MapKit

public class TicketFeature: GeoFeature<TicketFeature.Properties>, FGDDecodableFeature {
    
    public struct Properties: Codable {
        public let name: String
        public let type: String
    }
    
}

extension TicketFeature: StylableFeature {
    
    public func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor.blue.withAlphaComponent(0.5)
        overlayRenderer.fillColor = UIColor.blue.withAlphaComponent(0.3)
        overlayRenderer.lineWidth = 1.0
    }
    
}

extension TicketFeature {
    
    public func toAnnotation() -> TicketAnnotation {
        
        let coordinate = self.geometry.first?.coordinate ?? kCLLocationCoordinate2DInvalid
        
        return TicketAnnotation(
            title: properties.name,
            coordinate: coordinate
        )
        
    }
    
}
