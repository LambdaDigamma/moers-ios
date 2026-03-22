//
//  ToiletFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MapKit

public struct ToiletProperties: Codable {
    public let name: String
    public let type: String
}

public class ToiletFeature: GeoFeature<ToiletProperties>, FGDDecodableFeature {
    
    public typealias Properties = ToiletProperties
    
}

extension ToiletFeature: StylableFeature {
    
    public func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.3)
        overlayRenderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.2)
        overlayRenderer.lineWidth = 1.0
    }
    
}

extension ToiletFeature {
    
    public func toAnnotation() -> ToiletAnnotation {
        
        let coordinate = self.geometry.first?.coordinate ?? kCLLocationCoordinate2DInvalid
        
        return ToiletAnnotation(
            title: properties.name,
            coordinate: coordinate
        )
        
    }
    
}
