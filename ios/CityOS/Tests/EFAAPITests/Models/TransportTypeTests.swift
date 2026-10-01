//
//  TransportTypeTests.swift
//  
//
//  Created by Lennart Fischer on 25.07.20.
//

import Foundation
import XCTest
@testable import EFAAPI

@MainActor
class TransportTypeTests: XCTestCase {
    
    func test_raw_transport_type_init_train() async {
        XCTAssertEqual(TransportType(rawValue: 0), TransportType.train)
    }
    
    func test_raw_transport_type_init_suburbanRailway() async {
        XCTAssertEqual(TransportType(rawValue: 1), TransportType.suburbanRailway)
    }
    
    func test_raw_transport_type_init_subway() async {
        XCTAssertEqual(TransportType(rawValue: 2), TransportType.subway)
    }
    
    func test_raw_transport_type_init_metro() async {
        XCTAssertEqual(TransportType(rawValue: 3), TransportType.metro)
    }
    
    func test_raw_transport_type_init_tram() async {
        XCTAssertEqual(TransportType(rawValue: 4), TransportType.tram)
    }
    
    func test_raw_transport_type_init_cityBus() async {
        XCTAssertEqual(TransportType(rawValue: 5), TransportType.cityBus)
    }
    
    func test_raw_transport_type_init_regionalBus() async {
        XCTAssertEqual(TransportType(rawValue: 6), TransportType.regionalBus)
    }
    
    func test_raw_transport_type_init_rapidBus() async {
        XCTAssertEqual(TransportType(rawValue: 7), TransportType.rapidBus)
    }
    
    func test_raw_transport_type_init_cableCar() async {
        XCTAssertEqual(TransportType(rawValue: 8), TransportType.cableCar)
    }
    
    func test_raw_transport_type_init_onCallBus() async {
        XCTAssertEqual(TransportType(rawValue: 10), TransportType.onCallBus)
    }
    
    func test_raw_transport_type_init_suspensionRailway() async {
        XCTAssertEqual(TransportType(rawValue: 11), TransportType.suspensionRailway)
    }
    
    func test_raw_transport_type_init_plane() async {
        XCTAssertEqual(TransportType(rawValue: 12), TransportType.plane)
    }
    
    func test_raw_transport_type_init_regionalTrain() async {
        XCTAssertEqual(TransportType(rawValue: 13), TransportType.regionalTrain)
    }
    
    func test_raw_transport_type_init_nationalTrain() async {
        XCTAssertEqual(TransportType(rawValue: 14), TransportType.nationalTrain)
    }
    
    func test_raw_transport_type_init_internationalTrain() async {
        XCTAssertEqual(TransportType(rawValue: 15), TransportType.internationalTrain)
    }
    
    func test_raw_transport_type_init_highSpeedTrain() async {
        XCTAssertEqual(TransportType(rawValue: 16), TransportType.highSpeedTrain)
    }
    
    func test_raw_transport_type_init_railReplacementService() async {
        XCTAssertEqual(TransportType(rawValue: 17), TransportType.railReplacementService)
    }
    
    func test_raw_transport_type_init_shuttleTrain() async {
        XCTAssertEqual(TransportType(rawValue: 18), TransportType.shuttleTrain)
    }
    
    func test_raw_transport_type_init_communityBus() async {
        XCTAssertEqual(TransportType(rawValue: 19), TransportType.communityBus)
    }
    
    
}
