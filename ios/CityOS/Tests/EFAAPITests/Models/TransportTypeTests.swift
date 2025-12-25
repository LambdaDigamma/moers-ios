//
//  TransportTypeTests.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XCTest
@testable import EFAAPI

class TransportTypeTests: XCTestCase {
    
    func test_raw_transport_type_init_train() {
        XCTAssertEqual(TransportType(rawValue: 0), TransportType.train)
    }
    
    func test_raw_transport_type_init_suburbanRailway() {
        XCTAssertEqual(TransportType(rawValue: 1), TransportType.suburbanRailway)
    }
    
    func test_raw_transport_type_init_subway() {
        XCTAssertEqual(TransportType(rawValue: 2), TransportType.subway)
    }
    
    func test_raw_transport_type_init_metro() {
        XCTAssertEqual(TransportType(rawValue: 3), TransportType.metro)
    }
    
    func test_raw_transport_type_init_tram() {
        XCTAssertEqual(TransportType(rawValue: 4), TransportType.tram)
    }
    
    func test_raw_transport_type_init_cityBus() {
        XCTAssertEqual(TransportType(rawValue: 5), TransportType.cityBus)
    }
    
    func test_raw_transport_type_init_regionalBus() {
        XCTAssertEqual(TransportType(rawValue: 6), TransportType.regionalBus)
    }
    
    func test_raw_transport_type_init_rapidBus() {
        XCTAssertEqual(TransportType(rawValue: 7), TransportType.rapidBus)
    }
    
    func test_raw_transport_type_init_cableCar() {
        XCTAssertEqual(TransportType(rawValue: 8), TransportType.cableCar)
    }
    
    func test_raw_transport_type_init_onCallBus() {
        XCTAssertEqual(TransportType(rawValue: 10), TransportType.onCallBus)
    }
    
    func test_raw_transport_type_init_suspensionRailway() {
        XCTAssertEqual(TransportType(rawValue: 11), TransportType.suspensionRailway)
    }
    
    func test_raw_transport_type_init_plane() {
        XCTAssertEqual(TransportType(rawValue: 12), TransportType.plane)
    }
    
    func test_raw_transport_type_init_regionalTrain() {
        XCTAssertEqual(TransportType(rawValue: 13), TransportType.regionalTrain)
    }
    
    func test_raw_transport_type_init_nationalTrain() {
        XCTAssertEqual(TransportType(rawValue: 14), TransportType.nationalTrain)
    }
    
    func test_raw_transport_type_init_internationalTrain() {
        XCTAssertEqual(TransportType(rawValue: 15), TransportType.internationalTrain)
    }
    
    func test_raw_transport_type_init_highSpeedTrain() {
        XCTAssertEqual(TransportType(rawValue: 16), TransportType.highSpeedTrain)
    }
    
    func test_raw_transport_type_init_railReplacementService() {
        XCTAssertEqual(TransportType(rawValue: 17), TransportType.railReplacementService)
    }
    
    func test_raw_transport_type_init_shuttleTrain() {
        XCTAssertEqual(TransportType(rawValue: 18), TransportType.shuttleTrain)
    }
    
    func test_raw_transport_type_init_communityBus() {
        XCTAssertEqual(TransportType(rawValue: 19), TransportType.communityBus)
    }
    
    static var allTests = [
        ("test_raw_transport_type_init_train", test_raw_transport_type_init_train),
        ("test_raw_transport_type_init_suburbanRailway", test_raw_transport_type_init_suburbanRailway),
        ("test_raw_transport_type_init_subway", test_raw_transport_type_init_subway),
        ("test_raw_transport_type_init_metro", test_raw_transport_type_init_metro),
        ("test_raw_transport_type_init_tram", test_raw_transport_type_init_tram),
        ("test_raw_transport_type_init_cityBus", test_raw_transport_type_init_cityBus),
        ("test_raw_transport_type_init_regionalBus", test_raw_transport_type_init_regionalBus),
        ("test_raw_transport_type_init_rapidBus", test_raw_transport_type_init_rapidBus),
        ("test_raw_transport_type_init_cableCar", test_raw_transport_type_init_cableCar),
        ("test_raw_transport_type_init_onCallBus", test_raw_transport_type_init_onCallBus),
        ("test_raw_transport_type_init_suspensionRailway", test_raw_transport_type_init_suspensionRailway),
        ("test_raw_transport_type_init_nationalTrain", test_raw_transport_type_init_nationalTrain),
        ("test_raw_transport_type_init_internationalTrain", test_raw_transport_type_init_internationalTrain),
        ("test_raw_transport_type_init_highSpeedTrain", test_raw_transport_type_init_highSpeedTrain),
        ("test_raw_transport_type_init_railReplacementService", test_raw_transport_type_init_railReplacementService),
        ("test_raw_transport_type_init_shuttleTrain", test_raw_transport_type_init_shuttleTrain),
        ("test_raw_transport_type_init_communityBus", test_raw_transport_type_init_communityBus),
    ]
    
}
