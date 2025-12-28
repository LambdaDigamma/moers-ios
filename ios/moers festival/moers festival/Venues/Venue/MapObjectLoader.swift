//
//  MapObjectLoader.swift
//  moers festival
//
//  Created by Lennart Fischer on 09.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Foundation
import MapKit

public class GenericMapObject: NSObject, MKGeoJSONObject {
    
    
    
}

public class MapObjectLoader {
    
    public init() {}
    
    public func loadOverlays() -> [MKMultiPolygon] {
        
        var polygons: [MKMultiPolygon] = []
        
        do {
            
            guard let url = Bundle.main.url(forResource: "intermediate", withExtension: "geojson") else { return [] }
            
            let data = try Data(contentsOf: url)
            let decoder = MKGeoJSONDecoder()
            let propDecoder = JSONDecoder()
            
            guard let featureCollection = try decoder.decode(data) as? [MKGeoJSONFeature] else { return [] }
            
            print("Loaded objects")
            
            featureCollection
                .forEach { (feature: MKGeoJSONFeature) in
                    
                    guard let geometry = feature.geometry.first, let propData = feature.properties else { return }
                    
                    if let polygon = geometry as? MKMultiPolygon {
                        
                        if let decodedData = try? propDecoder.decode([String: String?].self, from: propData) {
                            polygon.title = decodedData["name"] ?? ""
                        }
                        
                        polygons.append(polygon)
                        
                    }
                    
                }
            
        } catch {
            print("Failed loading map objects")
            print(error)
        }
        
        print(polygons)
        
        return polygons
        
    }
    
    
}
