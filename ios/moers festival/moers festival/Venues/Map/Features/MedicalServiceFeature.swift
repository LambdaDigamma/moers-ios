//
//  MedicalServiceFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MapKit

public class MedicalServiceFeature: GeoFeature<MedicalServiceFeature.Properties>, FGDDecodableFeature {
    
    public struct Properties: Codable {
        public let name: String
        public let type: String
    }
    
}

extension MedicalServiceFeature: StylableFeature {
    
    public func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.3)
        overlayRenderer.fillColor = UIColor.systemGreen.withAlphaComponent(0.2)
        overlayRenderer.lineWidth = 1.0
    }
    
}

extension MedicalServiceFeature {
    
    public func toAnnotation() -> MedicalServiceAnnotation {
        return MedicalServiceAnnotation(
            title: self.properties.name,
            coordinate: geometry.first?.coordinate ?? kCLLocationCoordinate2DInvalid
        )
    }
    
}
