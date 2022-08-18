//
//  GeoJSONDecoderTests.swift
//  
//
//  Created by Lennart Fischer on 10.05.22.
//

import Foundation
import XCTest
@testable import Core
import MapKit

final class GeoJSONDecoderTests: XCTestCase {
    
    func testDecodeBasicMultiPolygon() throws {
        
        let data = """
        {
            "type": "FeatureCollection",
            "features": [
                {
                    "type": "Feature",
                    "id": 1,
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
        """.data(using: .utf8)!
        
        let decoder = GeoJSONDecoder()
        let results = try decoder.decode(data: data)
        
        XCTAssertEqual(results.count, 1)
        XCTAssertNotNil(results.first?.identifier)
        XCTAssertEqual(results.first?.identifier, "1")
        XCTAssert(results.first?.geometry.first is MKMultiPolygon)
        
    }
    
}
