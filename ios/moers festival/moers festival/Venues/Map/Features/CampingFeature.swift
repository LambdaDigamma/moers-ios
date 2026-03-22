//
//  CampingFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MapKit

public struct CampingProperties: Codable {
    public let name: String
    public let type: String
}

public class CampingFeature: GeoFeature<CampingProperties>, FGDDecodableFeature {
    
    public typealias Properties = CampingProperties
    
}

extension CampingFeature: StylableFeature {
    
    public func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.3)
        overlayRenderer.fillColor = UIColor.systemGreen.withAlphaComponent(0.2)
        overlayRenderer.lineWidth = 1.0
    }
    
}
