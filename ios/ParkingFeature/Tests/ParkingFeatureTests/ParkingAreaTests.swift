//
//  ParkingAreaTests.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import XCTest
import Core
@testable import ParkingFeature

final class ParkingAreaTests: XCTestCase {
    
    func test_openingStateRawValues() {
        
        XCTAssertEqual(ParkingAreaOpeningState.closed.rawValue, "closed")
        XCTAssertEqual(ParkingAreaOpeningState.open.rawValue, "open")
        XCTAssertEqual(ParkingAreaOpeningState.unknown.rawValue, "unknown")
        
    }
    
    func test_initAndFree() {
        
        let model = ParkingArea(
            id: 1,
            name: "Kastell",
            location: Point(latitude: 50, longitude: 6),
            currentOpeningState: .closed,
            capacity: 200,
            occupiedSites: 123,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(model.id, 1)
        XCTAssertEqual(model.name, "Kastell")
        XCTAssertEqual(model.location?.latitude, 50)
        XCTAssertEqual(model.location?.longitude, 6)
        XCTAssertEqual(model.currentOpeningState, .closed)
        XCTAssertEqual(model.capacity, 200)
        XCTAssertEqual(model.occupiedSites, 123)
        XCTAssertEqual(model.freeSites, 77)
        XCTAssertNotNil(model.createdAt)
        XCTAssertNotNil(model.updatedAt)
        
    }
    
    public func test_decode() throws {

        let decoder = JSONDecoder()
        let dataString = """
        {
            "id": 1,
            "name": "Kautzstr.",
            "location": {
                "type": "Point",
                "coordinates": [
                    51.449781,
                    6.631362
                ]
            },
            "current_opening_state": "open",
            "capacity": 62,
            "occupied_sites": 11,
            "created_at": null,
            "updated_at": null
        }
        """

        guard let data = dataString.data(using: .utf8) else { fatalError() }
        let model = try decoder.decode(ParkingArea.self, from: data)
        
        XCTAssertEqual(model.location?.latitude, 6.631362)
        XCTAssertEqual(model.location?.longitude, 51.449781)

    }
    
}
