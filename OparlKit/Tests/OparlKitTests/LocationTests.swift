//
//  LocationTests.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation
import XCTest
@testable import OparlKit

class LocationTests: XCTestCase {
    
    func testDecode() throws {
        
        let data = """
        {
            "id": "https://oparl.example.org/location/0",
            "type": "https://schema.oparl.org/1.1/Location",
            "description": "Rathaus der Beispielstadt, Ratshausplatz 1, 12345 Beispielstadt",
            "created": "2014-01-08T14:28:31+01:00",
            "modified": "2014-01-08T14:28:31+01:00",
            "geojson": {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [
                        50.1234,
                        10.4321
                    ]
                },
                "properties": {
                    "name": "Rathausplatz"
                }
            }
        }
        """
        
        let decoder = OparlDecoder()
        let location = try decoder.decode(Location.self, from: data.data(using: .utf8)!)
        
        XCTAssertEqual(location.id, "https://oparl.example.org/location/0")
        XCTAssertEqual(location.type, "https://schema.oparl.org/1.1/Location")
        XCTAssertEqual(location.description, "Rathaus der Beispielstadt, Ratshausplatz 1, 12345 Beispielstadt")
        XCTAssertNotNil(location.created)
        XCTAssertNotNil(location.modified)
        
    }
    
}
