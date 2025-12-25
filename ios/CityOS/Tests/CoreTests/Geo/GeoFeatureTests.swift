//
//  GeoFeatureTests.swift
//  
//
//  Created by Lennart Fischer on 10.05.22.
//

import Foundation
import XCTest
import MapKit
@testable import Core

final class GeoFeatureTests: XCTestCase {
    
    func testDecode() throws {
        
        guard let feature = try createJSONFeature().first else { return XCTFail("No feature found.") }
        
        let parsedFeature = try GeoFeature<[String: String?]>(feature: feature)
        
        XCTAssertEqual(parsedFeature.properties["name"], "Festivalhalle")
        XCTAssert(parsedFeature.geometry.first is MKMultiPolygon)
        
    }
    
    func createJSONFeature() throws -> [MKGeoJSONFeature] {
        
        let data = """
        {
            "type": "FeatureCollection",
            "features": [
                {
                    "type": "Feature",
                    "properties": {
                        "name": "Festivalhalle"
                    },
                    "geometry": {
                        "type": "MultiPolygon",
                        "coordinates": [[[
                            [6.619598698405006, 51.44015195855422],
                            [6.619343805384543, 51.43984048532275],
                            [6.618511033532068, 51.440111384703506],
                            [6.618769742531335, 51.440420173704524],
                            [6.619598698405006, 51.44015195855422]
                        ]]]
                    }
                }
            ]
        }
        """
        
        let decoder = GeoJSONDecoder()
        
        return try decoder.decode(data: data.data(using: .utf8)!)
        
    }
    
}
