//
//  TicketFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MapKit

public struct TicketProperties: Codable {
    public let name: String
    public let type: String
}

public class TicketFeature: GeoFeature<TicketProperties>, FGDDecodableFeature {
    
    public typealias Properties = TicketProperties
    
}

extension TicketFeature: StylableFeature {
    
    public func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.systemBlue.withAlphaComponent(0.7)
                : UIColor.blue.withAlphaComponent(0.5)
        }
        overlayRenderer.fillColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.systemBlue.withAlphaComponent(0.4)
                : UIColor.blue.withAlphaComponent(0.3)
        }
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
