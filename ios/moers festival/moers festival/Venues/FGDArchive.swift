//
//  FGDArchive.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import Foundation
import MapKit

protocol FGDDecodableFeature {
    init(feature: MKGeoJSONFeature) throws
}

public enum FGDError: Error {
    case invalidType
    case invalidData
}

public struct FGDArchive {
    
    public let baseDirectory: URL
    
    public init(directory: URL) {
        baseDirectory = directory
    }
    
    public enum File {
        
        case camping
        case dorf
        case medical_service
        case stages
        case surfaces
        case tickets
        case toilets
        case transportation
        
        public var filename: String {
            return "\(self).geojson"
        }
        
    }
    
    public func fileURL(for file: File) -> URL {
        return baseDirectory.appendingPathComponent(file.filename)
    }
    
}
