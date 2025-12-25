//
//  ObjectFilterTests.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XCTest
@testable import EFAAPI

class ObjectFilterTests: XCTestCase {
    
    func test_no_filter() {
        let fullSearchFilter: ObjectFilter = [.noFilter]
        XCTAssertEqual(fullSearchFilter.rawValue, 0)
    }
    
    // Test Simple Object Filter Types
    
    func test_place_filter() {
        let placeFilter: ObjectFilter = [.places]
        XCTAssertEqual(placeFilter.rawValue, 1)
    }
    
    func test_stop_filter() {
        let stopFilter: ObjectFilter = [.stops]
        XCTAssertEqual(stopFilter.rawValue, 2)
    }
    
    func test_street_filter() {
        let streetFilter: ObjectFilter = [.streets]
        XCTAssertEqual(streetFilter.rawValue, 4)
    }
    
    func test_address_filter() {
        let addressFilter: ObjectFilter = [.addresses]
        XCTAssertEqual(addressFilter.rawValue, 8)
    }
    
    func test_crossing_filter() {
        let crossingFilter: ObjectFilter = [.crossing]
        XCTAssertEqual(crossingFilter.rawValue, 16)
    }
    
    func test_poi_filter() {
        let poiFilter: ObjectFilter = [.pointsOfInterest]
        XCTAssertEqual(poiFilter.rawValue, 32)
    }
    
    func test_postcode_filter() {
        let postcodeFilter: ObjectFilter = [.postcode]
        XCTAssertEqual(postcodeFilter.rawValue, 64)
    }
    
    // Test Complex Object Filter Combinations
    
    func test_stationAndPOIs_filter() {
        let stationsAndPOIsFilter: ObjectFilter = [.stops, .pointsOfInterest]
        XCTAssertEqual(stationsAndPOIsFilter.rawValue, 34)
    }
    
    func test_placesAndStreets_filter() {
        let placesAndStreetsFilter: ObjectFilter = [.places, .streets]
        XCTAssertEqual(placesAndStreetsFilter.rawValue, 5)
    }
    
    func test_crossingsAndAddressesAndPostcodes_filter() {
        let intersectionsAndAddressesAndPostcodesFilter: ObjectFilter =
            [.crossing, .addresses, .postcode]
        XCTAssertEqual(intersectionsAndAddressesAndPostcodesFilter.rawValue, 88)
    }
    
    static var allTests = [
        ("test_no_filter", test_no_filter),
        ("test_place_filter", test_place_filter),
        ("test_stop_filter", test_stop_filter),
        ("test_street_filter", test_street_filter),
        ("test_address_filter", test_address_filter),
        ("test_crossing_filter", test_crossing_filter),
        ("test_poi_filter", test_poi_filter),
        ("test_postcode_filter", test_postcode_filter),
        ("test_stationAndPOIs_filter", test_stationAndPOIs_filter),
        ("test_placesAndStreets_filter", test_placesAndStreets_filter),
        ("test_crossingsAndAddressesAndPostcodes_filter", test_crossingsAndAddressesAndPostcodes_filter),
    ]
    
}
