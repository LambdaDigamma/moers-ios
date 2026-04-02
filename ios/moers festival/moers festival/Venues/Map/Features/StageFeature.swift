//
//  StageFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MapKit

public struct StageProperties: Codable {
    public let name: String
    public let type: String
}

public class StageFeature: GeoFeature<StageProperties>, FGDDecodableFeature {
    
    public typealias Properties = StageProperties
    
}

extension StageFeature: StylableFeature {
    
    public func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.5)
                : UIColor.black.withAlphaComponent(0.5)
        }
        overlayRenderer.fillColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.2)
                : UIColor.black.withAlphaComponent(0.2)
        }
        overlayRenderer.lineWidth = 1.0
    }
    
}
