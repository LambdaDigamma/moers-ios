//
//  GeoFeature.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Foundation
import MapKit

public enum GeoFeatureDecoding {
    
    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
}

public enum GeoFeatureError: LocalizedError {
    case invalidData
}

open class GeoFeature<Properties: Decodable>: NSObject {
    
    public let identifier: UUID
    public let properties: Properties
    public let geometry: [MKShape & MKGeoJSONObject]
    
    public required init(feature: MKGeoJSONFeature) throws {
        
        let uuidString = feature.identifier
        
        if let uuidString = uuidString {
            self.identifier = UUID(uuidString: uuidString) ?? UUID()
        } else {
            self.identifier = UUID()
        }
        
        if let propertiesData = feature.properties {
            properties = try GeoFeatureDecoding.decoder.decode(Properties.self, from: propertiesData)
        } else {
            throw GeoFeatureError.invalidData
        }
        
        self.geometry = feature.geometry
        
        super.init()
    }
    
}
