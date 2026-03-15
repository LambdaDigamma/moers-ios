//
//  TransportationFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MapKit

public class TransportationFeature: GeoFeature<TransportationFeature.Properties>, FGDDecodableFeature {
    
    public struct Properties: Codable {
        public let name: String
        public let type: String
    }
    
}

extension TransportationFeature: StylableFeature {
    
    public func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor.systemYellow.withAlphaComponent(0.5)
        overlayRenderer.fillColor = UIColor.systemYellow.withAlphaComponent(0.4)
        overlayRenderer.lineWidth = 1.0
    }
    
}

extension TransportationFeature {
    
    public func toAnnotation() -> BikeAnnotation {
        
        return BikeAnnotation(
            title: properties.name,
            coordinate: geometry.first?.coordinate ?? kCLLocationCoordinate2DInvalid
        )
        
    }
    
}
