//
//  PointTests.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import XCTest
import CoreLocation
@testable import Core

final class PointTests: XCTestCase {
    
    public func test_init() {
        
        let point = Point(latitude: 51.1234, longitude: 6.624)
        
        XCTAssertEqual(point.latitude, 51.1234)
        XCTAssertEqual(point.longitude, 6.624)
        
    }
    
    public func test_encode() throws {
        
        let point = Point(latitude: 51.1234, longitude: 6.624)
        let encoder = JSONEncoder()
        
        let data = try encoder.encode(point)
        let dataString = String(data: data, encoding: .utf8)
        
        XCTAssertEqual(dataString, "{\"type\":\"Point\",\"coordinates\":[51.123399999999997,6.6239999999999997]}")
        
    }
    
    public func test_decode() throws {
        
        let decoder = JSONDecoder()
        let dataString = """
        {
            "type": "Point",
            "coordinates": [
                51.0,
                7.0
            ]
        }
        """
        
        guard let data = dataString.data(using: .utf8) else { fatalError() }
        let point = try decoder.decode(Point.self, from: data)
        
        XCTAssertEqual(point.latitude, 51.0)
        XCTAssertEqual(point.longitude, 7.0)
        
    }
    
    public func test_decodeThrows_pointInvalidNumberOfCoordinates() throws {
        
        let decoder = JSONDecoder()
        let dataString = """
        {
            "type": "Point",
            "coordinates": [
                51.0
            ]
        }
        """
        
        guard let data = dataString.data(using: .utf8) else { fatalError() }
        
        do {
            _ = try decoder.decode(Point.self, from: data)
        } catch GeoJSONDecodingError.pointInvalidNumberOfCoordinates {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Didn't throw the right error")
        }
        
    }
    
    public func test_toCoordinate() {
        
        let point = Point(latitude: 51.45, longitude: 6.5)
        
        XCTAssertEqual(point.toCoordinate().latitude, 51.45)
        XCTAssertEqual(point.toCoordinate().longitude, 6.5)
        
    }
    
}
