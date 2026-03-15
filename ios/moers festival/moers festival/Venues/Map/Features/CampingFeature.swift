//
//  CampingFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MapKit

public class CampingFeature: GeoFeature<CampingFeature.Properties>, FGDDecodableFeature {
    
    public struct Properties: Codable {
        public let name: String
        public let type: String
    }
    
}

extension CampingFeature: StylableFeature {
    
    public func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.3)
        overlayRenderer.fillColor = UIColor.systemGreen.withAlphaComponent(0.2)
        overlayRenderer.lineWidth = 1.0
    }
    
}
