//
//  StageFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MapKit

public class StageFeature: GeoFeature<StageFeature.Properties>, FGDDecodableFeature {
    
    public struct Properties: Codable {
        public let name: String
        public let type: String
    }
    
}

extension StageFeature: StylableFeature {
    
    public func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor.black.withAlphaComponent(0.5)
        overlayRenderer.fillColor = UIColor.black.withAlphaComponent(0.2)
        overlayRenderer.lineWidth = 1.0
    }
    
}

