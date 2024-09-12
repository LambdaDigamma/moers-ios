//
//  GeoJSONDecoder.swift
//  
//
//  Created by Lennart Fischer on 10.05.22.
//

import Foundation
import MapKit

public class GeoJSONDecoder {
    
    let decoder: MKGeoJSONDecoder
    
    public init(decoder: MKGeoJSONDecoder = .init()) {
        
        self.decoder = decoder
        
    }
    
    public func decode(data: Data) throws -> [MKGeoJSONFeature] {
        
        guard let featureCollection = try decoder.decode(data) as? [MKGeoJSONFeature] else { return [] }
        
        return featureCollection
        
    }
    
}
