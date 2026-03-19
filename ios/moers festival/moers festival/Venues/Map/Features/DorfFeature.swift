//
//  DorfFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import MapKit

public struct DorfProperties: Codable {
    public let name: String?
    public let type: String?
    public let food: Int?
    public let boothNo: Int?
    public let description: String?
    
    var isFood: Bool {
        return food == 1
    }
    
    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<DorfProperties.CodingKeys> = try decoder.container(
            keyedBy: DorfProperties.CodingKeys.self
        )
        self.name = try container.decodeIfPresent(String.self, forKey: DorfProperties.CodingKeys.name)
        self.type = try container.decodeIfPresent(String.self, forKey: DorfProperties.CodingKeys.type)
        self.food = try container.decodeIfPresent(Int.self, forKey: DorfProperties.CodingKeys.food)
        self.boothNo = try container.decodeIfPresent(Int.self, forKey: DorfProperties.CodingKeys.boothNo)
        self.description = try container.decodeIfPresent(String.self, forKey: DorfProperties.CodingKeys.description)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case food
        case boothNo
        case description = "desc"
    }
    
}

public class DorfFeature: GeoFeature<DorfProperties>, FGDDecodableFeature {
    
    public typealias Properties = DorfProperties
    
}

extension DorfFeature: StylableFeature {
    
    public func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor.black.withAlphaComponent(0.3)
        overlayRenderer.fillColor = UIColor.black.withAlphaComponent(0.2)
        overlayRenderer.lineWidth = 1.0
    }
    
}

extension DorfFeature {
    
    public func toAnnotation() -> DorfAnnotation {
        
        return DorfAnnotation(
            title: properties.name ?? "",
            coordinate: geometry.first?.coordinate ?? kCLLocationCoordinate2DInvalid
        )
        
    }
    
}
