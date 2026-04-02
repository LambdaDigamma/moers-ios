//
//  MedicalServiceFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MapKit

public struct MedicalServiceProperties: Codable {
    public let name: String
    public let type: String
}

public class MedicalServiceFeature: GeoFeature<MedicalServiceProperties>, FGDDecodableFeature {
    
    public typealias Properties = MedicalServiceProperties
    
}

extension MedicalServiceFeature: StylableFeature {
    
    public func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.systemGreen.withAlphaComponent(0.5)
                : UIColor.systemGreen.withAlphaComponent(0.3)
        }
        overlayRenderer.fillColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.systemGreen.withAlphaComponent(0.3)
                : UIColor.systemGreen.withAlphaComponent(0.2)
        }
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
