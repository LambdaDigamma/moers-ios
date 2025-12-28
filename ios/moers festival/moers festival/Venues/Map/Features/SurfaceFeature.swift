//
//  SurfaceFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MapKit

// - Surfaces nur Umranden
// - Toiletten
// - Medical Service nur Annotation mit Kreuz
// - Hütten solider einfärben
// -


public class SurfaceFeature: GeoFeature<SurfaceFeature.Properties>, FGDDecodableFeature {
    
    public struct Properties: Codable {
        public let name: String
        public let type: String
        public var fenced: Bool = false
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.type = try container.decode(String.self, forKey: .type)
            self.fenced = try container.decodeIfPresent(Bool.self, forKey: .fenced) ?? false
        }
        
        public enum CodingKeys: String, CodingKey {
            case name = "name"
            case type = "type"
            case fenced = "fenced"
        }
        
    }
    
}

extension SurfaceFeature: StylableFeature {
    
    public func configure(overlayRenderer: MKOverlayPathRenderer) {
        
        overlayRenderer.strokeColor = UIColor.systemBrown.withAlphaComponent(self.properties.fenced ? 0.8 : 0.2)
        overlayRenderer.fillColor = UIColor.systemBrown.withAlphaComponent(0.0)
        overlayRenderer.lineWidth = self.properties.fenced ? 2.0 : 1.0
    }
    
}
